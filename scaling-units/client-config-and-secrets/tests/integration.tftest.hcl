run "test_integration_as_dependency" {
  command = plan

  variables {
    location           = "East US"
    vnet_name          = "integration-vnet"
    vnet_resource_id   = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/integration-rg/providers/Microsoft.Network/virtualNetworks/integration-vnet"
    subnet_name        = "integration-subnet"
    subnet_resource_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/integration-rg/providers/Microsoft.Network/virtualNetworks/integration-vnet/subnets/integration-subnet"
    suffix             = "int01"
    tags = {
      Environment = "integration"
      Purpose     = "testing"
    }
  }

  # Test that the module can be used as a dependency by validating all outputs are available
  assert {
    condition     = output.resource_group_id != ""
    error_message = "Resource group ID output must be available for dependent modules"
  }

  assert {
    condition     = output.resource_group_name != ""
    error_message = "Resource group name output must be available for dependent modules"
  }

  assert {
    condition     = output.key_vault_id != ""
    error_message = "Key Vault ID output must be available for dependent modules"
  }

  assert {
    condition     = output.key_vault_name != ""
    error_message = "Key Vault name output must be available for dependent modules"
  }

  assert {
    condition     = output.key_vault_uri != ""
    error_message = "Key Vault URI output must be available for dependent modules"
  }

  assert {
    condition     = output.app_configuration_id != ""
    error_message = "App Configuration ID output must be available for dependent modules"
  }

  assert {
    condition     = output.app_configuration_name != ""
    error_message = "App Configuration name output must be available for dependent modules"
  }

  assert {
    condition     = output.app_configuration_endpoint != ""
    error_message = "App Configuration endpoint output must be available for dependent modules"
  }

  # Test private endpoint outputs
  assert {
    condition     = output.key_vault_private_endpoint_id != ""
    error_message = "Key Vault private endpoint ID must be available for dependent modules"
  }

  assert {
    condition     = output.app_configuration_private_endpoint_id != ""
    error_message = "App Configuration private endpoint ID must be available for dependent modules"
  }

  # Test DNS zone outputs
  assert {
    condition     = output.key_vault_private_dns_zone_name == "privatelink.vaultcore.azure.net"
    error_message = "Key Vault private DNS zone name must be correct for dependent modules"
  }

  assert {
    condition     = output.app_configuration_private_dns_zone_name == "privatelink.azconfig.io"
    error_message = "App Configuration private DNS zone name must be correct for dependent modules"
  }

  assert {
    condition     = output.key_vault_private_dns_zone_id != ""
    error_message = "Key Vault private DNS zone ID must be available for dependent modules"
  }

  assert {
    condition     = output.app_configuration_private_dns_zone_id != ""
    error_message = "App Configuration private DNS zone ID must be available for dependent modules"
  }
}

run "test_integration_module_reusability" {
  command = plan

  variables {
    location           = "West US 2"
    vnet_name          = "reuse-test-vnet"
    vnet_resource_id   = "/subscriptions/11111111-1111-1111-1111-111111111111/resourceGroups/reuse-rg/providers/Microsoft.Network/virtualNetworks/reuse-test-vnet"
    subnet_name        = "reuse-subnet"
    subnet_resource_id = "/subscriptions/11111111-1111-1111-1111-111111111111/resourceGroups/reuse-rg/providers/Microsoft.Network/virtualNetworks/reuse-test-vnet/subnets/reuse-subnet"
    suffix             = "reuse01"
    key_vault_sku      = "premium"
    app_configuration_sku = "standard"
    tags = {
      Environment = "test"
      Module      = "client-config-and-secrets"
      Reusable    = "true"
    }
  }

  # Test that the module can be reused with different configurations
  assert {
    condition     = azurerm_key_vault.this.sku_name == "premium"
    error_message = "Module should be reusable with different SKU configurations"
  }

  assert {
    condition     = azurerm_app_configuration.this.sku == "standard"
    error_message = "Module should be reusable with different App Configuration SKU"
  }

  assert {
    condition     = azurerm_resource_group.this.location == "West US 2"
    error_message = "Module should be reusable in different regions"
  }

  # Test that outputs are consistently formatted for reusability
  assert {
    condition     = can(regex("^/subscriptions/.*/resourceGroups/.*/providers/Microsoft.Resources/resourceGroups/.*", output.resource_group_id))
    error_message = "Resource group ID should follow Azure resource ID format"
  }

  assert {
    condition     = can(regex("^/subscriptions/.*/resourceGroups/.*/providers/Microsoft.KeyVault/vaults/.*", output.key_vault_id))
    error_message = "Key Vault ID should follow Azure resource ID format"
  }

  assert {
    condition     = can(regex("^/subscriptions/.*/resourceGroups/.*/providers/Microsoft.AppConfiguration/configurationStores/.*", output.app_configuration_id))
    error_message = "App Configuration ID should follow Azure resource ID format"
  }

  assert {
    condition     = can(regex("^https://.*\\.vault\\.azure\\.net/$", output.key_vault_uri))
    error_message = "Key Vault URI should follow expected format"
  }

  assert {
    condition     = can(regex("^https://.*\\.azconfig\\.io$", output.app_configuration_endpoint))
    error_message = "App Configuration endpoint should follow expected format"
  }
}

run "test_integration_idempotency" {
  command = plan

  variables {
    location           = "East US 2"
    vnet_name          = "idempotent-vnet"
    vnet_resource_id   = "/subscriptions/22222222-2222-2222-2222-222222222222/resourceGroups/idempotent-rg/providers/Microsoft.Network/virtualNetworks/idempotent-vnet"
    subnet_name        = "idempotent-subnet"
    subnet_resource_id = "/subscriptions/22222222-2222-2222-2222-222222222222/resourceGroups/idempotent-rg/providers/Microsoft.Network/virtualNetworks/idempotent-vnet/subnets/idempotent-subnet"
    suffix             = "idem01"
    tags = {
      Test = "idempotency"
    }
  }

  # Test that the module configuration is idempotent
  assert {
    condition     = azurerm_key_vault.this.soft_delete_retention_days == 7
    error_message = "Key Vault soft delete settings should be consistent"
  }

  assert {
    condition     = azurerm_key_vault.this.purge_protection_enabled == false
    error_message = "Key Vault purge protection should be consistently configured"
  }

  assert {
    condition     = azurerm_key_vault.this.public_network_access_enabled == false
    error_message = "Key Vault public access should be consistently disabled"
  }

  assert {
    condition     = azurerm_app_configuration.this.public_network_access == "Disabled"
    error_message = "App Configuration public access should be consistently disabled"
  }

  assert {
    condition     = azurerm_app_configuration.this.local_auth_enabled == true
    error_message = "App Configuration local auth should be consistently enabled"
  }

  # Test that private DNS zone configuration is idempotent
  assert {
    condition     = azurerm_private_dns_zone_virtual_network_link.key_vault.registration_enabled == false
    error_message = "DNS zone registration should be consistently configured"
  }

  assert {
    condition     = azurerm_private_dns_zone_virtual_network_link.app_configuration.registration_enabled == false
    error_message = "DNS zone registration should be consistently configured"
  }
}
