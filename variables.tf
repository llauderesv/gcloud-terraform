variable "project_id" {
  description = "Google Cloud Project id"
  sensitive   = true
}

variable "sql_host" {
  description = "SQL Host Name"
  sensitive = true
}

variable "sql_password" {
  description = "SQL Password"
  sensitive = true
}

variable "sql_username" {
  description = "SQL Username"
  sensitive = true
}
