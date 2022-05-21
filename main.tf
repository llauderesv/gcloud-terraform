terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.20.0"
    }
  }

  cloud {
    organization = "example-org-bins"

    workspaces {
      name = "gcp_terraform"
    }
  }
}

locals {
  name_suffix = "e-commerce"
  region      = "asia-east1"
}

provider "google" {
  project = var.project_id
  region  = local.region
}

# See versions at https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database_instance#database_version
resource "google_sql_database_instance" "my_database_instance_e_commerce" {
  database_version    = "MYSQL_8_0"
  deletion_protection = true
  name                = "my-database-instance-${local.name_suffix}"
  region              = local.region

  settings {
    activation_policy     = "ALWAYS"
    availability_type     = "ZONAL"
    disk_autoresize       = true
    disk_autoresize_limit = 0
    disk_size             = 10
    disk_type             = "PD_SSD"
    pricing_plan          = "PER_USE"
    tier                  = "db-f1-micro"
    user_labels           = {}

    backup_configuration {
      binary_log_enabled             = false
      enabled                        = false
      point_in_time_recovery_enabled = false
      start_time                     = "04:00"
      transaction_log_retention_days = 7

      backup_retention_settings {
        retained_backups = 7
        retention_unit   = "COUNT"
      }
    }

    ip_configuration {
      ipv4_enabled = true
      require_ssl  = false
      authorized_networks {
        name  = "Local Machine"
        value = "136.158.7.165"
      }
    }

    location_preference {
      zone = "asia-east1-a"
    }
  }

}

// Project ID format in GCP projects/friendly-slate-338113/instances/my-database-instance-e-commerce/databases/my-database-e-commerce
resource "google_sql_database" "database" {
  instance = google_sql_database_instance.my_database_instance_e_commerce.name
  name     = "my-database-${local.name_suffix}"
}

resource "random_id" "db_name_suffix" {
  byte_length = 4
}

resource "google_sql_user" "users" {
  name     = "user"
  password = "user${random_id.db_name_suffix.hex}"
  instance = google_sql_database_instance.my_database_instance_e_commerce.name
  host     = google_sql_database_instance.my_database_instance_e_commerce.public_ip_address
}

resource "null_resource" "setup_db" {
  depends_on = [google_sql_database.database, google_sql_user.users]
  provisioner "local-exec" {
    command = "mysql -h ${var.sql_host} -u ${google_sql_user.users.name} -p${google_sql_user.users.password} < setup.sql"
  }
}

output "db_password" {
  description = "Database Password"
  value       = google_sql_user.users.password
  sensitive   = true
}

// Get all available regions in GCP
# data "google_compute_regions" "available" {
# }

# output "all_regions" {
#   value = data.google_compute_regions.available.names
#   description = "Display the available regions in GCP."
# }
