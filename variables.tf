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
  type        = string
  default     = "hochschule-burgenland"
}

variable "subnet_cidr" {
  description = "Primary subnet CIDR."
  type        = string
  default     = "10.10.0.0/20"
}

variable "pods_cidr" {
  description = "Secondary range for GKE pods."
  type        = string
  default     = "10.20.0.0/16"
}

variable "services_cidr" {
  description = "Secondary range for GKE services."
  type        = string
  default     = "10.30.0.0/20"
}
