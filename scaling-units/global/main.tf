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

# Create the DNS zone
resource "azurerm_dns_zone" "this" {
  name                = module.naming.dns_zone.name
  resource_group_name = azurerm_resource_group.this.name
  tags                = var.tags
}
