terraform {
  backend "gcs" {
    bucket  = "nazwa-twojego-bucket-na-state"
    prefix  = "terraform/state"
  }
}

