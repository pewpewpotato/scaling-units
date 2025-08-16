# Use azure/naming module for consistent naming conventions
module "naming" {
  source  = "azure/naming/azurerm"
  version = "~> 0.4"
  suffix  = [var.suffix]
}

# Create resource group
resource "azurerm_resource_group" "main" {
  name     = module.naming.resource_group.name
  location = var.location
  tags     = var.tags
}

# Create Azure Front Door CDN Profile
resource "azurerm_cdn_frontdoor_profile" "main" {
  name                = module.naming.frontdoor.name
  resource_group_name = azurerm_resource_group.main.name
  sku_name            = var.sku
  tags                = var.tags
}
