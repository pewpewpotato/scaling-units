run "test_documentation_exists" {
  command = plan

  variables {
    location          = "East US"
    vnet_name         = "test-vnet"
    vnet_resource_id  = "/subscriptions/test/resourceGroups/test/providers/Microsoft.Network/virtualNetworks/test-vnet"
    subnet_name       = "test-subnet"
    subnet_resource_id = "/subscriptions/test/resourceGroups/test/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/test-subnet"
    suffix            = "test01"
    tags = {
      environment = "test"
    }
  }

  # This test just ensures the module can plan successfully
  # The actual documentation testing would be manual verification
  assert {
    condition     = length(azurerm_resource_group.this.name) > 0
    error_message = "Module should plan successfully for documentation testing"
  }
}
