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

# Create the virtual network
resource "azurerm_virtual_network" "this" {
  name                = module.naming.virtual_network.name
  address_space       = [var.vnet_address_space]
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = var.tags
}

# Create the network security group
resource "azurerm_network_security_group" "this" {
  name                = module.naming.network_security_group.name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = var.tags
}

# Create the core subnet
resource "azurerm_subnet" "core" {
  name                 = "core"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [var.core_subnet_prefix]
}

# Associate NSG with the core subnet
resource "azurerm_subnet_network_security_group_association" "core" {
  subnet_id                 = azurerm_subnet.core.id
  network_security_group_id = azurerm_network_security_group.this.id
}
