#!/usr/bin/env bash
# =============================================================================
# bootstrap.sh — One-Time Infrastructure Bootstrap
#
# This script handles the chicken-and-egg setup that CI/CD needs to exist
# BEFORE Terraform can run. After running this once, all future deployments
# are fully automated via git push → GitHub Actions → Terraform.
#
# Usage:
#   chmod +x bootstrap.sh
#   ./bootstrap.sh
#
# Prerequisites:
#   - gcloud CLI installed and authenticated (gcloud auth login)
#   - gh CLI installed and authenticated (gh auth login)
#   - A GCP project already created
#   - A GitHub repository already created
# =============================================================================
set -euo pipefail

# ---------------------------------------------------------------------------
# Configuration — Edit these values for your project
# ---------------------------------------------------------------------------
GCP_PROJECT_ID="project-6cdce5b2-1881-424f-a94"
GCP_REGION="us-central1"
GH_REPO="yisakm9/portfolio-serverless-gcp"
SA_NAME="yisak-portfolio-gh-sa"
SA_DISPLAY="Portfolio GitHub Actions SA"
WIF_POOL="github-pool"
WIF_PROVIDER="github-provider"
TF_STATE_BUCKET="yisak-portfolio-tf-state"
GH_ORG="yisakm9"  # GitHub org or username for WIF attribute condition

# ---------------------------------------------------------------------------
# Helper functions
# ---------------------------------------------------------------------------
info()  { echo -e "\033[1;34m[INFO]\033[0m  $1"; }
ok()    { echo -e "\033[1;32m[OK]\033[0m    $1"; }
warn()  { echo -e "\033[1;33m[WARN]\033[0m  $1"; }
error() { echo -e "\033[1;31m[ERROR]\033[0m $1"; exit 1; }

check_tool() {
  command -v "$1" &>/dev/null || error "$1 is required but not installed."
}

# ---------------------------------------------------------------------------
# Pre-flight checks
# ---------------------------------------------------------------------------
info "Running pre-flight checks..."
check_tool gcloud
check_tool gh
check_tool terraform
ok "All required tools installed"

# Set active project
gcloud config set project "$GCP_PROJECT_ID" --quiet
ok "GCP project set to $GCP_PROJECT_ID"

# Get project number (needed for WIF)
PROJECT_NUMBER=$(gcloud projects describe "$GCP_PROJECT_ID" --format='value(projectNumber)')
ok "Project number: $PROJECT_NUMBER"

# ---------------------------------------------------------------------------
# Step 1: Enable Required GCP APIs
# ---------------------------------------------------------------------------
info "Step 1/7: Enabling GCP APIs..."
APIS=(
  "cloudfunctions.googleapis.com"
  "cloudbuild.googleapis.com"
  "artifactregistry.googleapis.com"
  "run.googleapis.com"
  "compute.googleapis.com"
  "firestore.googleapis.com"
  "secretmanager.googleapis.com"
  "iam.googleapis.com"
  "iamcredentials.googleapis.com"
  "cloudresourcemanager.googleapis.com"
  "sts.googleapis.com"
  "monitoring.googleapis.com"
  "logging.googleapis.com"
  "storage.googleapis.com"
)
gcloud services enable "${APIS[@]}" --quiet
ok "All APIs enabled"

# ---------------------------------------------------------------------------
# Step 2: Create Terraform State Bucket
# ---------------------------------------------------------------------------
info "Step 2/7: Setting up Terraform state bucket..."
if gsutil ls -b "gs://$TF_STATE_BUCKET" &>/dev/null; then
  ok "State bucket gs://$TF_STATE_BUCKET already exists"
else
  gsutil mb -p "$GCP_PROJECT_ID" -l "$GCP_REGION" "gs://$TF_STATE_BUCKET"
  gsutil versioning set on "gs://$TF_STATE_BUCKET"
  ok "Created state bucket gs://$TF_STATE_BUCKET with versioning"
fi

# ---------------------------------------------------------------------------
# Step 3: Create GitHub Actions Service Account
# ---------------------------------------------------------------------------
info "Step 3/7: Setting up GitHub Actions service account..."
SA_EMAIL="${SA_NAME}@${GCP_PROJECT_ID}.iam.gserviceaccount.com"

if gcloud iam service-accounts describe "$SA_EMAIL" &>/dev/null 2>&1; then
  ok "Service account $SA_EMAIL already exists"
else
  gcloud iam service-accounts create "$SA_NAME" \
    --display-name="$SA_DISPLAY" \
    --project="$GCP_PROJECT_ID"
  ok "Created service account $SA_EMAIL"
fi

# Grant admin role (as user requested)
info "  Granting roles/owner to GitHub Actions SA..."
gcloud projects add-iam-policy-binding "$GCP_PROJECT_ID" \
  --member="serviceAccount:$SA_EMAIL" \
  --role="roles/owner" \
  --quiet > /dev/null
ok "SA has owner role on project"

# ---------------------------------------------------------------------------
# Step 4: Create Workload Identity Federation
# ---------------------------------------------------------------------------
info "Step 4/7: Setting up Workload Identity Federation..."

# Create WIF pool (idempotent)
if gcloud iam workload-identity-pools describe "$WIF_POOL" \
    --location="global" --project="$GCP_PROJECT_ID" &>/dev/null 2>&1; then
  ok "WIF pool '$WIF_POOL' already exists"
else
  gcloud iam workload-identity-pools create "$WIF_POOL" \
    --location="global" \
    --display-name="GitHub Actions Pool" \
    --project="$GCP_PROJECT_ID"
  ok "Created WIF pool '$WIF_POOL'"
fi

# Create OIDC provider (idempotent — update if exists)
PROVIDER_EXISTS=$(gcloud iam workload-identity-pools providers describe "$WIF_PROVIDER" \
  --workload-identity-pool="$WIF_POOL" \
  --location="global" \
  --project="$GCP_PROJECT_ID" 2>&1 || true)

if echo "$PROVIDER_EXISTS" | grep -q "name:"; then
  info "  WIF provider '$WIF_PROVIDER' exists, updating..."
  gcloud iam workload-identity-pools providers update-oidc "$WIF_PROVIDER" \
    --workload-identity-pool="$WIF_POOL" \
    --location="global" \
    --project="$GCP_PROJECT_ID" \
    --issuer-uri="https://token.actions.githubusercontent.com" \
    --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.repository=assertion.repository,attribute.repository_owner=assertion.repository_owner" \
    --attribute-condition="assertion.repository_owner == '$GH_ORG'"
  ok "Updated WIF provider '$WIF_PROVIDER'"
else
  gcloud iam workload-identity-pools providers create-oidc "$WIF_PROVIDER" \
    --workload-identity-pool="$WIF_POOL" \
    --location="global" \
    --project="$GCP_PROJECT_ID" \
    --issuer-uri="https://token.actions.githubusercontent.com" \
    --allowed-audiences="https://iam.googleapis.com/projects/$PROJECT_NUMBER/locations/global/workloadIdentityPools/$WIF_POOL/providers/$WIF_PROVIDER" \
    --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.repository=assertion.repository,attribute.repository_owner=assertion.repository_owner" \
    --attribute-condition="assertion.repository_owner == '$GH_ORG'"
  ok "Created WIF provider '$WIF_PROVIDER'"
fi

# Bind WIF to SA (idempotent)
WIF_MEMBER="principalSet://iam.googleapis.com/projects/$PROJECT_NUMBER/locations/global/workloadIdentityPools/$WIF_POOL/attribute.repository_owner/$GH_ORG"

gcloud iam service-accounts add-iam-policy-binding "$SA_EMAIL" \
  --role="roles/iam.workloadIdentityUser" \
  --member="$WIF_MEMBER" \
  --project="$GCP_PROJECT_ID" \
  --quiet > /dev/null 2>&1
ok "WIF → SA binding configured"

gcloud iam service-accounts add-iam-policy-binding "$SA_EMAIL" \
  --role="roles/iam.serviceAccountTokenCreator" \
  --member="$WIF_MEMBER" \
  --project="$GCP_PROJECT_ID" \
  --quiet > /dev/null 2>&1
ok "Token creator binding configured"

# ---------------------------------------------------------------------------
# Step 5: Set GitHub Repository Secrets
# ---------------------------------------------------------------------------
info "Step 5/7: Setting GitHub repository secrets..."

WIF_PROVIDER_FULL="projects/$PROJECT_NUMBER/locations/global/workloadIdentityPools/$WIF_POOL/providers/$WIF_PROVIDER"

gh secret set GCP_WORKLOAD_IDENTITY_PROVIDER --repo="$GH_REPO" --body="$WIF_PROVIDER_FULL"
ok "Set GCP_WORKLOAD_IDENTITY_PROVIDER"

gh secret set GCP_SERVICE_ACCOUNT_EMAIL --repo="$GH_REPO" --body="$SA_EMAIL"
ok "Set GCP_SERVICE_ACCOUNT_EMAIL"

# ---------------------------------------------------------------------------
# Step 6: Cloudflare API Token
# ---------------------------------------------------------------------------
info "Step 6/7: Cloudflare API Token..."



if [ -n "${CLOUDFLARE_API_TOKEN:-}" ]; then
  info "  Using CLOUDFLARE_API_TOKEN from environment"
else
  echo ""
  echo "  Enter your Cloudflare API Token (from https://dash.cloudflare.com/profile/api-tokens):"
  echo "  (needs Zone:DNS:Edit + Zone:Zone:Read permissions)"
  read -rsp "  Token: " CLOUDFLARE_API_TOKEN
  echo ""
fi

gh secret set CLOUDFLARE_API_TOKEN --repo="$GH_REPO" --body="$CLOUDFLARE_API_TOKEN"
ok "Set CLOUDFLARE_API_TOKEN in GitHub secrets"

# ---------------------------------------------------------------------------
# Step 7: SendGrid API Key
# ---------------------------------------------------------------------------
info "Step 7/7: SendGrid API Key..."

SECRET_EXISTS=$(gcloud secrets describe "sendgrid-api-key" --project="$GCP_PROJECT_ID" 2>&1 || true)

if echo "$SECRET_EXISTS" | grep -q "name:"; then
  # Check if it has any versions
  VERSION_COUNT=$(gcloud secrets versions list "sendgrid-api-key" \
    --project="$GCP_PROJECT_ID" --format='value(name)' 2>/dev/null | wc -l)
  if [ "$VERSION_COUNT" -gt 0 ]; then
    ok "SendGrid API key already configured (has $VERSION_COUNT version(s))"
  else
    echo ""
    echo "  SendGrid secret exists but has no value. Enter your SendGrid API Key:"
    read -rsp "  API Key: " SENDGRID_KEY
    echo ""
    echo -n "$SENDGRID_KEY" | gcloud secrets versions add "sendgrid-api-key" \
      --data-file=- --project="$GCP_PROJECT_ID"
    ok "SendGrid API key stored in Secret Manager"
  fi
else
  warn "SendGrid secret doesn't exist yet — Terraform will create it on first apply"
  echo ""
  echo "  After first Terraform apply, run:"
  echo "  echo -n 'YOUR_KEY' | gcloud secrets versions add sendgrid-api-key --data-file=- --project=$GCP_PROJECT_ID"
fi

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
echo ""
echo "============================================================================="
echo -e "\033[1;32m  ✅ BOOTSTRAP COMPLETE!\033[0m"
echo "============================================================================="
echo ""
echo "  What was set up:"
echo "    • GCP APIs enabled"
echo "    • Terraform state bucket: gs://$TF_STATE_BUCKET"
echo "    • GitHub Actions SA: $SA_EMAIL"
echo "    • Workload Identity Federation: $WIF_POOL/$WIF_PROVIDER"
echo "    • GitHub Secrets: GCP_WORKLOAD_IDENTITY_PROVIDER, GCP_SERVICE_ACCOUNT_EMAIL, CLOUDFLARE_API_TOKEN"
echo ""
echo "  Next steps:"
echo "    1. git push origin main"
echo "    2. Watch GitHub Actions: https://github.com/$GH_REPO/actions"
echo "    3. Your site will be live at https://yisakmesifin.org"
echo ""
echo "  To rebuild from scratch:"
echo "    1. terraform destroy"
echo "    2. git push (GitHub Actions runs terraform apply + frontend deploy)"
echo ""
echo "============================================================================="
