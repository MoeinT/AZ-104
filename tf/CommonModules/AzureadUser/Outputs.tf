output "user-object-id" {
  value = { for i, j in azuread_user.User : j.user_principal_name => j.object_id }
}