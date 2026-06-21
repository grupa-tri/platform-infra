locals {
  wi_pool = "${var.project_id}.svc.id.goog"
}

// External DNS IAM Resources
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

  depends_on = [google_container_cluster.cluster]
}

// CertManager IAM Resources
resource "google_service_account" "cert_manager" {
  account_id   = "${var.environment}-cert-manager"
  display_name = "cert-manager DNS-01"
}

resource "google_project_iam_member" "cert_manager_dns_admin" {
  project = var.project_id
  role    = "roles/dns.admin"
  member  = "serviceAccount:${google_service_account.cert_manager.email}"
}

resource "google_service_account_iam_member" "cert_manager_wi" {
  service_account_id = google_service_account.cert_manager.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${local.wi_pool}[cert-manager/cert-manager]"

  depends_on = [google_container_cluster.cluster]
}

// External Secrets IAM Resources
resource "google_service_account" "external_secrets" {
  account_id   = "${var.environment}-external-secrets"
  display_name = "External Secrets Operator"
}

resource "google_project_iam_member" "external_secrets_accessor" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.external_secrets.email}"
}

resource "google_service_account_iam_member" "external_secrets_wi" {
  service_account_id = google_service_account.external_secrets.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${local.wi_pool}[external-secrets/external-secrets]"

  depends_on = [google_container_cluster.cluster]
}

// Crossplane IAM Resources
resource "google_service_account" "crossplane" {
  account_id   = "${var.environment}-crossplane"
  display_name = "Crossplane GCP provider"
}


resource "google_project_iam_member" "crossplane_editor" {
  project = var.project_id
  role    = "roles/editor"
  member  = "serviceAccount:${google_service_account.crossplane.email}"
}

resource "google_service_account_iam_member" "crossplane_wi" {
  service_account_id = google_service_account.crossplane.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${local.wi_pool}[crossplane-system/crossplane]"

  depends_on = [google_container_cluster.cluster]
}

// Config Connector IAM Resources
resource "google_service_account" "config_connector" {
  account_id   = "${var.environment}-config-connector"
  display_name = "Config Connector"
}

resource "google_project_iam_member" "config_connector_owner" {
  project = var.project_id
  role    = "roles/owner"
  member  = "serviceAccount:${google_service_account.config_connector.email}"
}

resource "google_service_account_iam_member" "config_connector_workload_identity" {
  service_account_id = google_service_account.config_connector.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${local.wi_pool}[cnrm-system/cnrm-controller-manager]"
}