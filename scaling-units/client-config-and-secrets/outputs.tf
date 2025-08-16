output "resource_group_name" {
  description = "The name of the created resource group"
  value       = azurerm_resource_group.this.name
}

output "resource_group_id" {
  description = "The ID of the created resource group"
  value       = azurerm_resource_group.this.id
}

output "key_vault_name" {
  description = "The name of the created Key Vault"
  value       = azurerm_key_vault.this.name
}

output "key_vault_id" {
  description = "The ID of the created Key Vault"
  value       = azurerm_key_vault.this.id
}

output "key_vault_uri" {
  description = "The URI of the created Key Vault"
  value       = azurerm_key_vault.this.vault_uri
}

output "key_vault_private_endpoint_id" {
  description = "The ID of the Key Vault private endpoint"
  value       = azurerm_private_endpoint.key_vault.id
}

output "key_vault_private_dns_zone_name" {
  description = "The name of the Key Vault private DNS zone"
  value       = azurerm_private_dns_zone.key_vault.name
}

output "key_vault_private_dns_zone_id" {
  description = "The ID of the Key Vault private DNS zone"
  value       = azurerm_private_dns_zone.key_vault.id
}

output "app_configuration_name" {
  description = "The name of the created App Configuration"
  value       = azurerm_app_configuration.this.name
}

output "app_configuration_id" {
  description = "The ID of the created App Configuration"
  value       = azurerm_app_configuration.this.id
}

output "app_configuration_endpoint" {
  description = "The endpoint of the created App Configuration"
  value       = azurerm_app_configuration.this.endpoint
}

output "app_configuration_primary_read_key" {
  description = "The primary read key of the App Configuration"
  value       = azurerm_app_configuration.this.primary_read_key
  sensitive   = true
}

output "app_configuration_primary_write_key" {
  description = "The primary write key of the App Configuration"
  value       = azurerm_app_configuration.this.primary_write_key
  sensitive   = true
}

output "app_configuration_private_endpoint_id" {
  description = "The ID of the App Configuration private endpoint"
  value       = azurerm_private_endpoint.app_configuration.id
}

output "app_configuration_private_dns_zone_name" {
  description = "The name of the App Configuration private DNS zone"
  value       = azurerm_private_dns_zone.app_configuration.name
}

output "app_configuration_private_dns_zone_id" {
  description = "The ID of the App Configuration private DNS zone"
  value       = azurerm_private_dns_zone.app_configuration.id
}
