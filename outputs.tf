output "ssh_private_key" {
  value     = tls_private_key.ansible_ssh.private_key_openssh
  sensitive = true
}

#output "os_login_user" {
#  value = google_os_login_ssh_public_key.ansible.user
#}
