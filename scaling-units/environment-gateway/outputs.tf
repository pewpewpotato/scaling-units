output "apim_id" {
  description = "The ID of the created API Management instance"
  value       = azurerm_api_management.this.id
}

output "apim_name" {
  description = "The name of the created API Management instance"
  value       = azurerm_api_management.this.name
}

output "apim_gateway_url" {
  description = "The gateway URL of the API Management instance"
  value       = azurerm_api_management.this.gateway_url
}

output "apim_management_api_url" {
  description = "The management API URL of the API Management instance"
  value       = azurerm_api_management.this.management_api_url
}

output "subnet_id" {
  description = "The ID of the created or configured subnet for APIM"
  value       = azurerm_subnet.apim.id
}

output "subnet_name" {
  description = "The name of the created subnet for APIM"
  value       = azurerm_subnet.apim.name
}

output "resource_group_name" {
  description = "The name of the created resource group"
  value       = azurerm_resource_group.this.name
}

output "resource_group_id" {
  description = "The ID of the created resource group"
  value       = azurerm_resource_group.this.id
}
