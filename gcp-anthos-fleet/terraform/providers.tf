terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }

  # Bucket is passed at init time:
  #   terraform init -backend-config="bucket=<your-state-bucket>"
  backend "gcs" {
    prefix = "gcp-anthos-fleet"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region_a
}
