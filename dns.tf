resource "google_dns_managed_zone" "platform" {
  name        = "${var.environment}-platform-zone"
  dns_name    = var.domain_name
  description = "Public DNS zone for the Kubernetes platform assignment."

  visibility = "public"

  depends_on = [google_project_service.required_apis]
}