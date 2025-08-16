run "test_nsg_creation" {
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
    condition     = azurerm_network_security_group.this.location == "East US"
    error_message = "Network security group should be created in the specified location"
  }

  assert {
    condition     = contains(keys(azurerm_network_security_group.this.tags), "environment")
    error_message = "Network security group should include the specified tags"
  }
}
