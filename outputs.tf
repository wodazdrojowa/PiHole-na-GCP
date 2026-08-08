output "instance_ip" {
  value       = google_compute_address.pihole_ip.address
  description = "Public IP address of Pi-hole instance"
}

output "instance_name" {
  value       = google_compute_instance.pihole.name
  description = "Name of the instance"
}

output "ssh_private_key" {
  value     = tls_private_key.ansible_ssh.private_key_openssh
  sensitive = true
}

output "domain_name" {
  value       = var.domain_name
  description = "Subdomain for Pi-hole"
}

output "os_login_user" {
  value = "sa_${data.google_service_account.spacelift.unique_id}"
}