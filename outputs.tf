output "ssh_private_key" {
  value     = tls_private_key.ansible_ssh.private_key_openssh
  sensitive = true
}

output "domain_name" {
  value       = var.domain_name
  description = "Subdomain for Pi-hole"
}
