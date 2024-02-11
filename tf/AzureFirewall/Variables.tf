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
  validation {
    condition     = length(var.vm_admin_username) >= 8
    error_message = "The username should have at least 8 characters."
  }
}

variable "vm_admin_password" {
  type      = string
  sensitive = true

  validation {
    condition     = can(regex("[a-z]", var.vm_admin_password)) && can(regex("[A-Z]", var.vm_admin_password)) && can(regex("[0-9]", var.vm_admin_password)) && length(var.vm_admin_password) >= 8
    error_message = "Password must be at least 8 characters long and contain at least one uppercase letter, one lowercase letter, and one number."
  }
}

variable "source_addresses" {
  type      = string
  sensitive = true
}