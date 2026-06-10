resource "google_compute_network" "infra" {
  name                    = "${var.environment}-infra-vpc"
  auto_create_subnetworks = false

  depends_on = [google_project_service.required_apis]
}