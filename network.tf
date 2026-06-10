resource "google_compute_network" "infra" {
  name                    = "${var.environment}-infra-vpc"
  auto_create_subnetworks = false

  depends_on = [google_project_service.required_apis]
}

resource "google_compute_subnetwork" "infra" {
  name          = "${var.environment}-infra-subnet"
  region        = var.region
  network       = google_compute_network.infra.id
  ip_cidr_range = var.subnet_cidr
}