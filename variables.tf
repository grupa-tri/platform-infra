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