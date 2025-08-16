output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.this.name
}

output "resource_group_id" {
  description = "The ID of the resource group"
  value       = azurerm_resource_group.this.id
}

output "aca_environment_id" {
  description = "The ID of the Azure Container Apps Environment"
  value       = azurerm_container_app_environment.this.id
}

output "aca_environment_name" {
  description = "The name of the Azure Container Apps Environment"
  value       = azurerm_container_app_environment.this.name
}

output "cosmos_db_account_id" {
  description = "The ID of the Azure Cosmos DB Account"
  value       = azurerm_cosmosdb_account.this.id
}

output "cosmos_db_account_name" {
  description = "The name of the Azure Cosmos DB Account"
  value       = azurerm_cosmosdb_account.this.name
}

output "cosmos_db_account_endpoint" {
  description = "The endpoint of the Azure Cosmos DB Account"
  value       = azurerm_cosmosdb_account.this.endpoint
}

output "cosmos_db_primary_key" {
  description = "The primary key for the Azure Cosmos DB Account"
  value       = azurerm_cosmosdb_account.this.primary_key
  sensitive   = true
}

output "cosmos_db_secondary_key" {
  description = "The secondary key for the Azure Cosmos DB Account"
  value       = azurerm_cosmosdb_account.this.secondary_key
  sensitive   = true
}

output "cosmos_db_connection_strings" {
  description = "Connection strings for the Azure Cosmos DB Account"
  value = {
    primary   = azurerm_cosmosdb_account.this.primary_sql_connection_string
    secondary = azurerm_cosmosdb_account.this.secondary_sql_connection_string
  }
  sensitive = true
}

output "cosmos_db_private_endpoint_id" {
  description = "The ID of the Cosmos DB private endpoint"
  value       = azurerm_private_endpoint.cosmos_db.id
}

output "cosmos_db_private_endpoint_name" {
  description = "The name of the Cosmos DB private endpoint"
  value       = azurerm_private_endpoint.cosmos_db.name
}

output "cosmos_db_private_dns_zone_id" {
  description = "The ID of the Cosmos DB private DNS zone"
  value       = azurerm_private_dns_zone.cosmos_db.id
}

output "cosmos_db_private_dns_zone_name" {
  description = "The name of the Cosmos DB private DNS zone"
  value       = azurerm_private_dns_zone.cosmos_db.name
}

output "aca_nsg_id" {
  description = "The ID of the ACA Environment NSG"
  value       = azurerm_network_security_group.aca_environment.id
}

output "aca_nsg_name" {
  description = "The name of the ACA Environment NSG"
  value       = azurerm_network_security_group.aca_environment.name
}

output "cosmos_nsg_id" {
  description = "The ID of the Cosmos DB NSG"
  value       = azurerm_network_security_group.cosmos_db.id
}

output "cosmos_nsg_name" {
  description = "The name of the Cosmos DB NSG"
  value       = azurerm_network_security_group.cosmos_db.name
}

output "aca_nsg_subnet_association_id" {
  description = "The ID of the ACA NSG subnet association"
  value       = azurerm_subnet_network_security_group_association.aca_environment.id
}

output "cosmos_nsg_subnet_association_id" {
  description = "The ID of the Cosmos DB NSG subnet association"
  value       = azurerm_subnet_network_security_group_association.cosmos_db.id
}

output "aca_nsg_inbound_rules" {
  description = "All inbound rules configured in the ACA Environment NSG"
  value = [
    {
      name                       = "AllowContainerAppsHTTP"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "80"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    },
    {
      name                       = "AllowContainerAppsHTTPS"
      priority                   = 110
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  ]
}

output "cosmos_nsg_inbound_rules" {
  description = "All inbound rules configured in the Cosmos DB NSG"
  value = [
    {
      name                       = "AllowCosmosDBHTTPS"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  ]
}
