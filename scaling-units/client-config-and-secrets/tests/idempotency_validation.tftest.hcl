run "test_idempotency_validation" {
  command = plan

  variables {
    location          = "East US"
    vnet_name         = "test-vnet"
    vnet_resource_id  = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/network-rg/providers/Microsoft.Network/virtualNetworks/test-vnet"
    subnet_name       = "test-subnet"
    subnet_resource_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/network-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/test-subnet"
    suffix            = "test01"
    tags = {
      environment = "test"
      project     = "validation"
    }
  }

  # Test that resources are properly configured for idempotency
  assert {
    condition     = azurerm_key_vault.this.purge_protection_enabled == false
    error_message = "Key Vault purge protection should be disabled to allow idempotent operations"
  }

  assert {
    condition     = azurerm_key_vault.this.soft_delete_retention_days == 7
    error_message = "Key Vault soft delete retention should be set to minimum for faster testing"
  }

  # Test that all resources have consistent naming
  assert {
    condition     = can(regex("test01", azurerm_resource_group.this.name))
    error_message = "All resources should include the suffix for consistency"
  }

  assert {
    condition     = can(regex("test01", azurerm_key_vault.this.name))
    error_message = "Key Vault name should include the suffix for consistency"
  }

  assert {
    condition     = can(regex("test01", azurerm_app_configuration.this.name))
    error_message = "App Configuration name should include the suffix for consistency"
  }
}
