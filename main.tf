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
  project = var.project_id
  credentials = file("/mnt/workspace/gcp-key.json")
  region  = var.region
  zone    = var.zone
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
    ports    = ["51820"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["pihole"]
}

#resource "tls_private_key" "ssh_key" {
#  algorithm = "RSA"
#  rsa_bits  = 4096
#}

# Compute instance
resource "google_compute_instance" "pihole" {
  name         = var.machine_name
  machine_type = var.machine_type
  tags         = ["pihole"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 30    # 30GB is a maximum free size
      type = "pd-standard"  # HDD is free tier, SSD is paid
    }
  }

  network_interface {
    network = "default"
    access_config {
      nat_ip = google_compute_address.pihole_ip.address
    }
  }
#metadata = {
#    ssh-keys = "${var.ssh_user}:${tls_private_key.ssh_key.public_key_openssh}"
#  }

#  metadata = {
#    ssh-keys = "${var.ssh_user}:${file(var.ssh_public_key_path)}"
#  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y python3 python3-pip mc
  EOF

  service_account {
    scopes = ["cloud-platform"]
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

#output "ssh_public_key" {
#  value       = tls_private_key.ssh_key.public_key_openssh
#  description = "Public SSH key for Pi-hole instance"
#}

#output "ssh_private_key" {
#  value       = tls_private_key.ssh_key.private_key_pem
#  sensitive   = true
#  description = "Private SSH key - use to connect via SSH"
#}

resource "local_file" "ansible_inventory" {
  content = <<-EOF
    [pihole-server]
#    pihole-server ansible_host=${google_compute_address.pihole_ip.address} ansible_user=ansible ansible_ssh_private_key_file=/mnt/workspace/ssh_key/ssh_public
   pihole-server ansible_host=${google_compute_address.pihole_ip.address} ansible_user=

    [pihole-server:vars]
    ansible_python_interpreter=/usr/bin/python3
  EOF
  filename = "${path.module}/inventory.ini"
}
