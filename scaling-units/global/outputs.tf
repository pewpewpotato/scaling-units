output "name" {
  description = "The generated name using the naming convention"
  value       = module.naming.resource_group.name
}

output "resource_group_name" {
  description = "The name of the created resource group"
  value       = azurerm_resource_group.this.name
}

output "dns_zone_name" {
  description = "The name of the created DNS zone"
  value       = azurerm_dns_zone.this.name
}

output "resource_group_id" {
  description = "The ID of the created resource group"
  value       = azurerm_resource_group.this.id
}

output "dns_zone_id" {
  description = "The ID of the created DNS zone"
  value       = azurerm_dns_zone.this.id
}
