provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

data "google_client_config" "default" {}

provider "flux" {
  kubernetes = {
    host  = "https://${google_container_cluster.cluster.endpoint}"
    token = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(
      google_container_cluster.cluster.master_auth[0].cluster_ca_certificate
    )
  }

  git = {
    url    = var.git_url
    branch = var.git_branch

    http = {
      username = var.git_user
      password = var.git_token
    }
  }
}