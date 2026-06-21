terraform {
  backend "gcs" {
    bucket = "turing-cell-497816-p0-terraform-state"
    prefix = "platform-infra"
  }

  required_version = ">= 1.10.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.0"
    }
    flux = {
      source  = "fluxcd/flux"
      version = "~> 1.8"
    }
  }
}
