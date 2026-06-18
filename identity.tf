locals {
  wi_pool = "${var.project_id}.svc.id.goog"
}

resource "google_service_account" "external_dns" {
  account_id   = "${var.environment}-external-dns"
  display_name = "ExternalDNS"
}

resource "google_project_iam_member" "external_dns_admin" {
  project = var.project_id
  role    = "roles/dns.admin"
  member  = "serviceAccount:${google_service_account.external_dns.email}"
}

resource "google_service_account_iam_member" "external_dns_wi" {
  service_account_id = google_service_account.external_dns.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${local.wi_pool}[platform-system/external-dns]"
}