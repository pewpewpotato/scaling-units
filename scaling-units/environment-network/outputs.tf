output "virtual_network_name" {
  description = "The name of the created virtual network"
  value       = azurerm_virtual_network.this.name
}

output "virtual_network_id" {
  description = "The ID of the created virtual network"
  value       = azurerm_virtual_network.this.id
}

output "subnet_name" {
  description = "The name of the core subnet"
  value       = azurerm_subnet.core.name
}
