# =============================================================================
# Firestore Database — Serverless NoSQL
# GCP equivalent of: AWS DynamoDB
#
# IMPORTANT: The (default) Firestore database cannot be truly deleted in GCP.
# Even after deletion, the ID is reserved. We use deletion_policy = "ABANDON"
# so terraform destroy leaves it in place, and the import block in the root
# module auto-imports it on fresh deploys.
# =============================================================================

# Create Firestore database in Native mode
resource "google_firestore_database" "default" {
  name        = "(default)"
  project     = var.project_id
  location_id = var.region
  type        = "FIRESTORE_NATIVE"

  # Concurrency mode for better performance
  concurrency_mode            = "OPTIMISTIC"
  app_engine_integration_mode = "DISABLED"

  # Point-in-time recovery (equivalent to DynamoDB PITR)
  point_in_time_recovery_enablement = "POINT_IN_TIME_RECOVERY_ENABLED"

  # Prevent accidental deletion
  delete_protection_state = "DELETE_PROTECTION_DISABLED"

  # ABANDON on destroy — GCP doesn't allow deleting the (default) database.
  # On redeploy, the import block in the root module handles re-importing it.
  deletion_policy = "ABANDON"
}
