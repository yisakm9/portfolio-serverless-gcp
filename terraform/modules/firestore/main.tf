# =============================================================================
# Firestore Database — Serverless NoSQL
# GCP equivalent of: AWS DynamoDB
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
}
