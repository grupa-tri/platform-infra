locals {
  required_services = [
    "compute.googleapis.com",
    "container.googleapis.com",
    "dns.googleapis.com",
    "secretmanager.googleapis.com",
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "storage.googleapis.com",
    "logging.googleapis.com"
  ]
}

resource "google_project_service" "required_apis" {
  for_each = toset(local.required_services)

  service            = each.key
  disable_on_destroy = false
}