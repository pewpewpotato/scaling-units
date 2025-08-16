# Use azure/naming module for consistent naming conventions
module "naming" {
  source  = "azure/naming/azurerm"
  version = "~> 0.4"
  suffix  = [var.suffix]
}

# Create the resource group
resource "azurerm_resource_group" "this" {
  name     = module.naming.resource_group.name
  location = var.location
  tags     = var.tags
}

# Create the Azure Container Apps Environment
resource "azurerm_container_app_environment" "this" {
  name                       = module.naming.container_app_environment.name
  location                   = azurerm_resource_group.this.location
  resource_group_name        = azurerm_resource_group.this.name
  infrastructure_subnet_id   = var.aca_environment_subnet_id

  tags = var.tags
}

# Create the Azure Cosmos DB Account
resource "azurerm_cosmosdb_account" "this" {
  name                = module.naming.cosmosdb_account.name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  offer_type          = var.cosmos_db_sku

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = azurerm_resource_group.this.location
    failover_priority = 0
  }

  public_network_access_enabled = false

  tags = var.tags
}

# Create the private endpoint for Cosmos DB
resource "azurerm_private_endpoint" "cosmos_db" {
  name                = module.naming.private_endpoint.name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  subnet_id           = var.vnet_core_subnet_id

  private_service_connection {
    name                           = "${module.naming.cosmosdb_account.name}-connection"
    private_connection_resource_id = azurerm_cosmosdb_account.this.id
    subresource_names              = ["Sql"]
    is_manual_connection           = false
  }

  tags = var.tags
}

# Create the private DNS zone for Cosmos DB
resource "azurerm_private_dns_zone" "cosmos_db" {
  name                = "privatelink.documents.azure.com"
  resource_group_name = azurerm_resource_group.this.name

  tags = var.tags
}

# Link the private DNS zone to the VNET
resource "azurerm_private_dns_zone_virtual_network_link" "cosmos_db" {
  name                  = "${module.naming.cosmosdb_account.name}-dns-link"
  resource_group_name   = azurerm_resource_group.this.name
  private_dns_zone_name = azurerm_private_dns_zone.cosmos_db.name
  virtual_network_id    = var.vnet_id

  tags = var.tags
}

# Create NSG for ACA Environment
resource "azurerm_network_security_group" "aca_environment" {
  name                = "${module.naming.container_app_environment.name}-nsg"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  security_rule {
    name                       = "AllowContainerAppsHTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
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

  tags = var.tags
}

# Create NSG for Cosmos DB
resource "azurerm_network_security_group" "cosmos_db" {
  name                = "${module.naming.cosmosdb_account.name}-nsg"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  security_rule {
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

  tags = var.tags
}

# Associate NSG with ACA Environment subnet
resource "azurerm_subnet_network_security_group_association" "aca_environment" {
  subnet_id                 = var.aca_environment_subnet_id
  network_security_group_id = azurerm_network_security_group.aca_environment.id
}

# Associate NSG with Cosmos DB subnet (using core subnet)
resource "azurerm_subnet_network_security_group_association" "cosmos_db" {
  subnet_id                 = var.vnet_core_subnet_id
  network_security_group_id = azurerm_network_security_group.cosmos_db.id
}
