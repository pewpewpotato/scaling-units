# Test for Environment Compute and Storage Module - Naming Standards

provider "azurerm" {
  features {}
  skip_provider_registration = true
}

run "test_aca_environment_follows_naming_standards" {
  command = plan

  variables {
    location = "East US"
    tags = {
      environment = "test"
      project     = "environment-compute-and-storage"
    }
    suffix = "001"
    aca_environment_sku = "Consumption"
    aca_environment_subnet_id = "/subscriptions/test-sub/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/aca-subnet"
    cosmos_db_sku = "Standard"
    vnet_core_subnet_id = "/subscriptions/test-sub/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/core-subnet"
  }

  assert {
    condition     = can(regex("^cae-", azurerm_container_app_environment.this.name))
    error_message = "ACA Environment name should follow Azure naming standards and start with 'cae-'"
  }

  assert {
    condition     = can(regex("001$", azurerm_container_app_environment.this.name))
    error_message = "ACA Environment name should include the suffix at the end"
  }
}
