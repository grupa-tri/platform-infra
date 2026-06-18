output "dns_name_servers" {
  description = "Set these nameservers at your domain registrar."
  value       = google_dns_managed_zone.platform.name_servers
}