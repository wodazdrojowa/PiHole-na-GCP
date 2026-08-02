terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  project     = var.project_id
  credentials = file("/mnt/workspace/gcp-key.json")
  region      = var.region
  zone        = var.zone
}

# Static IP address
resource "google_compute_address" "pihole_ip" {
  name = "pihole-static-ip"
}

# Firewall rules
resource "google_compute_firewall" "pihole_ssh" {
  name    = "pihole-allow-ssh"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["pihole"]
}

resource "google_compute_firewall" "pihole_web" {
  name    = "pihole-allow-web"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["pihole"]
}

resource "google_compute_firewall" "pihole_dns" {
  name    = "pihole-allow-dns"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["53"]
  }

  allow {
    protocol = "udp"
    ports    = ["53"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["pihole"]
}

resource "google_compute_firewall" "pihole_wireguard" {
  name    = "pihole-allow-wireguard"
  network = "default"

  allow {
    protocol = "udp"
    ports    = ["443"]
    #zmieniłem domyślny port z 51280 na 443 bo coś operator komórkowy blokował wysokie porty
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["pihole"]
}

# 1. Generowanie pary kluczy SSH
resource "tls_private_key" "ansible_ssh" {
  algorithm = "ED25519"
}

# 2. Pobranie tożsamości service account
data "google_client_openid_userinfo" "me" {}

# 3. Rejestracja klucza publicznego w OS Login
resource "google_os_login_ssh_public_key" "ansible" {
  user = data.google_client_openid_userinfo.me.email
  key  = tls_private_key.ansible_ssh.public_key_openssh
}

# 4. Nadanie roli OS Login (używa zmiennej)
resource "google_project_iam_member" "os_login_admin" {
  project = var.project_id
  role    = "roles/compute.osAdminLogin"
  member  = "user:${var.os_login_user_email}"
}

# Compute instance
resource "google_compute_instance" "pihole" {
  name           = var.machine_name
  machine_type   = var.machine_type
  tags           = ["pihole"]
  can_ip_forward = true

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 30 # 30GB is a maximum free size
      type  = "pd-standard" # HDD is free tier, SSD is paid
    }
  }

  network_interface {
    network = "default"
    access_config {
      nat_ip = google_compute_address.pihole_ip.address
    }
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y python3 python3-pip
  EOF

  service_account {
    scopes = ["cloud-platform"]
  }

  metadata = {
    enable-oslogin = "TRUE"
  }
}

output "instance_ip" {
  value       = google_compute_address.pihole_ip.address
  description = "Public IP address of Pi-hole instance"
}

output "instance_name" {
  value       = google_compute_instance.pihole.name
  description = "Name of the instance"
}

# Zapis klucza prywatnego do pliku (dla Ansible)
resource "local_file" "ansible_ssh_private_key" {
  filename        = "./ansible_ssh_key"
  content         = tls_private_key.ansible_ssh.private_key_openssh
  file_permission = "0600"
}

# Inventory z poprawnym OS Login username
resource "local_file" "ansible_inventory" {
  filename = "./inventory.ini"
  content  = <<-EOT
[pihole-server]
pihole-server ansible_host=${google_compute_address.pihole_ip.address}

[pihole-server:vars]
ansible_user=sa_${data.google_service_account.spacelift.unique_id}
ansible_python_interpreter=/usr/bin/python3
ansible_ssh_private_key_file=./ansible_ssh_key
ansible_ssh_common_args=-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null
EOT
}

# Pobierz dane service account z unique_id
data "google_service_account" "spacelift" {
  account_id = "service-account-for-spacelift"
}

# Zmień output — POSIX username zamiast emaila
output "os_login_user" {
  value = "sa_${data.google_service_account.spacelift.unique_id}"
}