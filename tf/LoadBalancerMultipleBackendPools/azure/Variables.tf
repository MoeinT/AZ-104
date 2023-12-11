variable "env" {
  type = string
}

variable "vm_admin_username" {
  type      = string
  sensitive = true
}

variable "vm_admin_password" {
  type      = string
  sensitive = true
}

variable "vm_size" {
  type = string
}

variable "azuread_password" {
  type      = string
  sensitive = true
}

variable "ip_address" {
  type      = string
  sensitive = true
}

variable "vm_private_ip" {
  type      = string
  sensitive = true
}
