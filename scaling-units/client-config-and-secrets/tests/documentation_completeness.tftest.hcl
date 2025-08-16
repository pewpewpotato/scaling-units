run "test_documentation_completeness" {
  command = plan

  variables {
    location          = "East US"
    vnet_name         = "test-vnet"
    vnet_resource_id  = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/network-rg/providers/Microsoft.Network/virtualNetworks/test-vnet"
    subnet_name       = "test-subnet"
    subnet_resource_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/network-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/test-subnet"
    suffix            = "test01"
    # Test that tags default works (documentation should mention this)
    # Not providing tags to test the default
  }

  # This test ensures the module works with defaults as documented
  assert {
    condition     = length(azurerm_resource_group.this.name) > 0
    error_message = "Module should work with default values as documented"
  }

  # Test that common tags are automatically added
  assert {
    condition     = azurerm_resource_group.this.tags["ManagedBy"] == "OpenTofu"
    error_message = "Common tags should be automatically added as documented"
  }

  assert {
    condition     = azurerm_resource_group.this.tags["Module"] == "client-config-and-secrets"
    error_message = "Module tag should be automatically added as documented"
  }
}
