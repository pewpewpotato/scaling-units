run "test_naming_standards_compliance" {
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

  assert {
    condition     = can(regex("^rg-.*test01.*", azurerm_resource_group.this.name))
    error_message = "Resource group name should follow Azure naming convention with rg- prefix and suffix"
  }

  assert {
    condition     = can(regex("^kv-.*test01.*", azurerm_key_vault.this.name))
    error_message = "Key Vault name should follow Azure naming convention with kv- prefix and suffix"
  }

  assert {
    condition     = can(regex("^appcs-.*test01.*", azurerm_app_configuration.this.name))
    error_message = "App Configuration name should follow Azure naming convention with appcs- prefix and suffix"
  }
}
