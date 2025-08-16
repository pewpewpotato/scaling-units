# Use azure/naming module for consistent naming conventions
module "naming" {
  source  = "azure/naming/azurerm"
  version = "~> 0.4"
  suffix  = [var.suffix]
}

# Local values for consistency and reusability
locals {
  # Common tags that should be applied to all resources
  common_tags = merge(var.tags, {
    ManagedBy = "OpenTofu"
    Module    = "client-config-and-secrets"
  })

  # DNS zone names
  key_vault_dns_zone        = "privatelink.vaultcore.azure.net"
  app_configuration_dns_zone = "privatelink.azconfig.io"
}

# Create the resource group
resource "azurerm_resource_group" "this" {
  name     = module.naming.resource_group.name
  location = var.location
  tags     = local.common_tags

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags that might be added by external systems
      tags["CreatedOn"],
      tags["LastModified"]
    ]
  }
}

# Data source to get current client configuration
data "azurerm_client_config" "current" {}

# Create Azure Key Vault
resource "azurerm_key_vault" "this" {
  name                       = module.naming.key_vault.name
  location                   = azurerm_resource_group.this.location
  resource_group_name        = azurerm_resource_group.this.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = var.key_vault_sku
  soft_delete_retention_days = 7
  purge_protection_enabled   = false

  # Disable public network access since we're using private endpoints
  public_network_access_enabled = false

  # Allow access from Azure services
  network_acls {
    bypass         = "AzureServices"
    default_action = "Deny"
  }

  tags = local.common_tags

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags that might be added by external systems
      tags["CreatedOn"],
      tags["LastModified"]
    ]
  }
}

# Create private DNS zone for Key Vault
resource "azurerm_private_dns_zone" "key_vault" {
  name                = local.key_vault_dns_zone
  resource_group_name = azurerm_resource_group.this.name
  tags                = local.common_tags

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags that might be added by external systems
      tags["CreatedOn"],
      tags["LastModified"]
    ]
  }
}

# Create private DNS zone network link for Key Vault
resource "azurerm_private_dns_zone_virtual_network_link" "key_vault" {
  name                  = "${module.naming.key_vault.name}-link"
  resource_group_name   = azurerm_resource_group.this.name
  private_dns_zone_name = azurerm_private_dns_zone.key_vault.name
  virtual_network_id    = var.vnet_resource_id
  registration_enabled  = false
  tags                  = local.common_tags

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags that might be added by external systems
      tags["CreatedOn"],
      tags["LastModified"]
    ]
  }
}

# Create private endpoint for Key Vault
resource "azurerm_private_endpoint" "key_vault" {
  name                = "${module.naming.key_vault.name}-pe"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  subnet_id           = var.subnet_resource_id

  private_service_connection {
    name                           = "${module.naming.key_vault.name}-psc"
    private_connection_resource_id = azurerm_key_vault.this.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "key-vault-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.key_vault.id]
  }

  tags = local.common_tags

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags that might be added by external systems
      tags["CreatedOn"],
      tags["LastModified"]
    ]
  }
}

# Create Azure App Configuration
resource "azurerm_app_configuration" "this" {
  name                       = module.naming.app_configuration.name
  location                   = azurerm_resource_group.this.location
  resource_group_name        = azurerm_resource_group.this.name
  sku                        = var.app_configuration_sku
  public_network_access      = "Disabled"
  local_auth_enabled         = true

  tags = local.common_tags

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags that might be added by external systems
      tags["CreatedOn"],
      tags["LastModified"]
    ]
  }
}

# Create private DNS zone for App Configuration
resource "azurerm_private_dns_zone" "app_configuration" {
  name                = local.app_configuration_dns_zone
  resource_group_name = azurerm_resource_group.this.name
  tags                = local.common_tags

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags that might be added by external systems
      tags["CreatedOn"],
      tags["LastModified"]
    ]
  }
}

# Create private DNS zone network link for App Configuration
resource "azurerm_private_dns_zone_virtual_network_link" "app_configuration" {
  name                  = "${module.naming.app_configuration.name}-link"
  resource_group_name   = azurerm_resource_group.this.name
  private_dns_zone_name = azurerm_private_dns_zone.app_configuration.name
  virtual_network_id    = var.vnet_resource_id
  registration_enabled  = false
  tags                  = local.common_tags

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags that might be added by external systems
      tags["CreatedOn"],
      tags["LastModified"]
    ]
  }
}

# Create private endpoint for App Configuration
resource "azurerm_private_endpoint" "app_configuration" {
  name                = "${module.naming.app_configuration.name}-pe"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  subnet_id           = var.subnet_resource_id

  private_service_connection {
    name                           = "${module.naming.app_configuration.name}-psc"
    private_connection_resource_id = azurerm_app_configuration.this.id
    subresource_names              = ["configurationStores"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "app-config-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.app_configuration.id]
  }

  tags = local.common_tags

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags that might be added by external systems
      tags["CreatedOn"],
      tags["LastModified"]
    ]
  }
}
