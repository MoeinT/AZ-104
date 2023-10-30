variable "env" {
  description = "Environment for resources"
  type        = string
  validation {
    condition     = contains(["dev", "test", "qa", "prod"], var.env)
    error_message = "Environment should be either: dev, test, qa or prod."
  }
}

variable "vm_admin_username" {
  type      = string
  sensitive = true
}

variable "vm_admin_password" {
  type      = string
  sensitive = true
}