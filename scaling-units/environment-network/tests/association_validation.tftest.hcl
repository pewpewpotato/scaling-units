run "test_subnet_nsg_association" {
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
    condition     = azurerm_subnet_network_security_group_association.core.subnet_id != ""
    error_message = "NSG should be associated with the core subnet"
  }

  assert {
    condition     = azurerm_subnet_network_security_group_association.core.network_security_group_id != ""
    error_message = "NSG association should reference the created NSG"
  }
}
