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

  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = var.pods_cidr
  }

  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = var.services_cidr
  }
}

resource "google_compute_router" "infra" {
  name    = "${var.environment}-infra-router"
  region  = var.region
  network = google_compute_network.infra.id
}

resource "google_compute_router_nat" "infra" {
  name                               = "${var.environment}-infra-nat"
  router                             = google_compute_router.infra.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}