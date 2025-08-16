run "test_vnet_creation" {
  command = plan

  variables {
    location           = "East US"
    vnet_address_space = "10.0.0.0/16"
    core_subnet_prefix = "10.0.1.0/24"
    tags = {
      environment = "test"
    }
    suffix = "test01"
  }

  assert {
    condition     = contains(azurerm_virtual_network.this.address_space, "10.0.0.0/16")
    error_message = "Virtual network should use the provided address space"
  }

  assert {
    condition     = azurerm_virtual_network.this.location == "East US"
    error_message = "Virtual network should be created in the specified location"
  }

  assert {
    condition     = contains(keys(azurerm_virtual_network.this.tags), "environment")
    error_message = "Virtual network should include the specified tags"
  }
}
