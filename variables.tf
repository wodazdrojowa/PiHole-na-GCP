variable "ssh_user" {
  description = "SSH username"
  type        = string
  default     = "ansible"
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}