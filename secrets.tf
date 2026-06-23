resource "google_secret_manager_secret" "pull_secret" {
  secret_id = "ghcr-dockerconfigjson"

  replication {
    auto {}
  }

  lifecycle {
    prevent_destroy = true
  }
}
