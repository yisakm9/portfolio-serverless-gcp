/**
 * Blog Posts — Static Data
 *
 * To add a new post:
 * 1. Add an object to this array
 * 2. git add, commit, push
 * 3. Pipeline auto-deploys — zero manual clicks
 *
 * Content supports basic formatting via the renderer in BlogModal.
 */

const posts = [
  {
    slug: 'zero-touch-gcp-deployment',
    title: 'Zero-Touch GCP Deployment: From Bootstrap to Production',
    date: '2026-04-06',
    excerpt:
      'How I built a fully automated, serverless portfolio deployment pipeline on GCP — from a single bootstrap script to production in under 5 minutes.',
    readTime: '5 min read',
    tags: ['GCP', 'Terraform', 'CI/CD'],
    content: `Building a portfolio website sounds simple, but building one that deploys itself with zero manual clicks? That's a different challenge entirely.

This portfolio runs on Google Cloud Platform using a fully serverless architecture: Cloud Functions for the backend, GCS + Cloud CDN for the frontend, Firestore for data, and Terraform managing everything as code.

## The Problem

Most tutorials show you how to set up infrastructure step by step — clicking through consoles, running scattered CLI commands, copying secrets by hand. That works once, but what happens when you need to tear everything down and rebuild? You're back to square one.

## The Solution: bootstrap.sh

I created a single, idempotent bootstrap script that handles ALL first-time setup:

- Enables 15 GCP APIs
- Creates the Terraform state bucket with versioning
- Sets up Workload Identity Federation (keyless auth)
- Creates a GitHub Actions service account with least-privilege IAM roles
- Configures all GitHub repository secrets
- Stores API keys in Secret Manager

Run it once, and you never touch the console again.

## Infrastructure as Code — Everything

DNS records? Terraform. SSL certificates? Google-managed, auto-renewed. Cloud Functions? Terraform. Even the Cloudflare DNS records are managed by a custom Terraform module.

The destroy workflow cleans up EVERYTHING — GCP resources AND DNS records. Then bootstrap.sh + git push rebuilds it all from scratch.

## Key Takeaway

If you can't destroy and rebuild your infrastructure with a single command, it's not truly automated. This portfolio proves that zero-touch deployment isn't just for big companies — it's achievable for personal projects too.`,
  },
  {
    slug: 'aws-to-gcp-migration',
    title: 'Migrating a Serverless Portfolio from AWS to GCP',
    date: '2026-04-05',
    excerpt:
      'A practical guide to migrating serverless infrastructure from AWS (Lambda, S3, CloudFront, DynamoDB) to GCP equivalents.',
    readTime: '4 min read',
    tags: ['AWS', 'GCP', 'Migration'],
    content: `When I decided to migrate my portfolio from AWS to GCP, I expected a simple service-for-service swap. The reality was more nuanced.

## Service Mapping

Here's how the services translate:

- **S3 Static Hosting** → GCS Bucket with website config
- **CloudFront** → Global Load Balancer + Cloud CDN
- **Lambda** → Cloud Functions (2nd Gen)
- **API Gateway** → Built into Cloud Functions (each gets its own URL)
- **DynamoDB** → Firestore (Native Mode)
- **SES** → Resend (via Secret Manager)
- **CloudWatch** → Cloud Monitoring
- **IAM OIDC** → Workload Identity Federation
- **Route 53** → Cloudflare DNS (Terraform-managed)

## Biggest Differences

**Authentication**: AWS uses OIDC providers for GitHub Actions. GCP uses Workload Identity Federation — more complex to set up, but truly keyless.

**API Routing**: AWS API Gateway gives you a single base URL with routes. GCP Cloud Functions each get their own URL. The frontend needs to know individual function URLs.

**Build Permissions**: Cloud Functions 2nd Gen uses Cloud Build under the hood. You need explicit IAM roles for the build service account — something AWS Lambda handles transparently.

## What I'd Do Differently

I'd set up Workload Identity Federation first before anything else. It's the foundation for keyless CI/CD and everything depends on it.`,
  },
  {
    slug: 'firestore-gotchas',
    title: 'The Firestore Default Database Gotcha (And How to Fix It)',
    date: '2026-04-06',
    excerpt:
      'GCP\'s Firestore default database can\'t be truly deleted. Here\'s how to make your Terraform idempotent anyway.',
    readTime: '3 min read',
    tags: ['GCP', 'Firestore', 'Terraform'],
    content: `I learned this the hard way: you can't delete the Firestore (default) database in GCP. Not really.

## The Problem

When you run terraform destroy, Terraform tries to delete the Firestore database. GCP accepts the request, but the database ID "(default)" is reserved indefinitely. When you try to redeploy with terraform apply, you get:

Error 409: Database already exists. Please use another database_id.

Your CI/CD pipeline is now broken, and you're back to manual intervention.

## The Fix

Two changes make this completely future-proof:

**1. deletion_policy = "ABANDON"**

Tell Terraform to ignore the database during destroy. Since GCP won't actually delete it anyway, there's no point trying.

**2. import block**

Add a Terraform import block in the root module. On fresh deploys, if the database already exists, Terraform imports it into state instead of trying to create it.

Together, these two changes mean:
- First deploy: creates the database
- Destroy: leaves it alone (it can't be deleted anyway)
- Redeploy: imports existing database seamlessly

Zero errors, zero manual intervention, truly idempotent.

## Lesson Learned

Not all cloud resources are created equal. Some can't be deleted, some take time to propagate, and some have hidden dependencies. Always test the full destroy → redeploy cycle before calling your infrastructure "production-ready."`,
  },
];

export default posts;
