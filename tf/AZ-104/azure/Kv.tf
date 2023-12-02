# # Create a key vault
# module "kv" {
#   source = "../../CommonModules/KeyVault"
#   env    = var.env
#   properties = {
#     "kv-az104-${var.env}" = {
#       resource_group_name = module.Rg.rg-names["az-104-${var.env}"],
#       location            = module.Rg.rg-locations["az-104-${var.env}"],
#       sku_name            = "standard",
#       tenant_id           = data.azurerm_client_config.current.tenant_id
#       tags                = { "TerraformDeveloper" = "Moein" },
#       # Resources outside the below subnet will be denied to access this keyvault
#       network_acls = {
#         bypass                     = "AzureServices",
#         default_action             = "Deny",
#         virtual_network_subnet_ids = [module.Subnets.subnet-id["SubNet-${var.env}"]],
#         ip_rules                   = [var.ip_address]
#       }
#     }
#   }
# }

# # Manage policies in the key vault 
# module "kvpolicies" {
#   source = "../../CommonModules/KVAccessPolicy"
#   properties = {
#     "user-permission-${var.env}" = {
#       key_vault_id       = module.kv.kv-id["kv-az104-${var.env}"],
#       object_id          = data.azurerm_client_config.current.object_id,
#       KeyPermissions     = ["Get", "List", "Create", "GetRotationPolicy", "SetRotationPolicy", "Delete", "Recover"],
#       SecretPermissions  = ["Get", "List", "Set"],
#       StoragePermissions = ["Get", "List"]
#     },
#     "kvkey-encryption-${var.env}" = {
#       key_vault_id   = module.kv.kv-id["kv-az104-${var.env}"],
#       object_id      = module.DiskEncryptionSet.encyptionset-principal-id["vm-linux-encryption-key-${var.env}"],
#       KeyPermissions = ["Get", "WrapKey", "UnwrapKey", "Create", "Delete", "Purge", "Recover", "Update", "List", "Decrypt", "Sign"]
#     }
#   }
# }

# # Create a key within a key vault
# module "kvKey" {
#   source = "../../CommonModules/KeyVaultKey"
#   properties = {
#     "vm-linux-key-${var.env}" = {
#       key_vault_id = module.kv.kv-id["kv-az104-${var.env}"],
#       key_type     = "RSA",
#       key_opts     = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"],
#       key_size     = 2048
#     }
#   }
# }

# # Disk Encryption Set 
# module "DiskEncryptionSet" {
#   source = "../../CommonModules/DiskEncryptionSet"
#   properties = {
#     "vm-linux-encryption-key-${var.env}" = {
#       resource_group_name = module.Rg.rg-names["az-104-${var.env}"],
#       location            = module.Rg.rg-locations["az-104-${var.env}"],
#       key_vault_key_id    = module.kvKey.kvkey-id["vm-linux-key-${var.env}"],
#       identity = {
#         type = "SystemAssigned"
#       }
#     }
#   }
# }