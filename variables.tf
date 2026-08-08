variable "user_email" {
  description = "User email"
  type        = string
  default     = ""
}

variable "os_login_user_email" {
  description = "User from OS Login, like: sa_84949439"
  type        = string
  default     = ""
}

variable "pihole_admin_password" {
  description = "Pi-Hole admin password"
  type        = string
  default     = "ChangeMe123!"
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key"
  type        = string
  default     = "/mnt/workspace/ssh_key/id_ed25519.pub"
}

variable "zone" {
  description = "Compute instance zone"
  type        = string
  default     = "europe-central2-a"
#  default     = "us-central1-a"
}

variable "region" {
  description = "Compute instance region"
  type        = string
  default     = "europe-central2"
#  default     = "us-central1"
}

variable "project_id" {
  description = "Project id"
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

variable "domain_name" {
  description = "Domain name for Let's Encrypt certificate and Pi-hole web interface. Must resolve to the instance public IP."
  type        = string
  default     = ""
}

variable "wireguard_port" {
  description = "WireGuard UDP port"
  type        = string
  default     = "51820"
}

variable "gcp_credentials_path" {
  description = "Path to GCP service account JSON key"
  type        = string
  default     = "/mnt/workspace/gcp-key.json"
}

variable "spacelift_service_account_id" {
  description = "GCP Service Account ID for Spacelift"
  type        = string
  default     = "service-account-for-spacelift"
}

variable "use_spot" {
  description = "Use spot instance (cheaper, may be preempted). Set to false if spot is unavailable in zone."
  type        = bool
  default     = true
}