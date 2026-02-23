variable "ssh_user" {
  description = "SSH username"
  type        = string
  default     = ""
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key"
  type        = string
  default     = "/mnt/workspace/id_ed25519.pub"
}

variable "zone" {
  description = "Compute instance zone "
  type        = string
  default     = "us-west1-b"
}

variable "region" {
  description = "Compute instance region"
  type        = string
  default     = "us-west1"
}

variable "project_id" {
  description = "Project id "
  type        = string
  default     = "github-test-terraform-v1"
}

variable "machine_type" {
  description = "Machine type"
  type        = string
  default     = "e2-micro"
}

variable "machine_name" {
  description = "Machine name"
  type        = string
  default     = "pihole-server"
}