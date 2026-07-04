output "ssh_private_key" {
  value     = tls_private_key.ansible_ssh.private_key_openssh
  sensitive = true
}
