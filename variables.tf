variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "Primary region"
  type        = string
  default     = "europe-west3"
}

variable "zone" {
  description = "Zone location"
  type        = string
  default     = "europe-west3-a"
}

variable "environment" {
  description = "Environment name used in resource names."
  type = string
  default = "hochschule-burgenland"
}
