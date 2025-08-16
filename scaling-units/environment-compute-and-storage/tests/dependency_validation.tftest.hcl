# Test for Environment Compute and Storage Module - Dependency Validation Tests

provider "azurerm" {
  features {}
  skip_provider_registration = true
}

run "test_missing_aca_environment_subnet_id" {
  command = plan

  variables {
    location = "East US"
    tags = {
      environment = "test"
      project     = "environment-compute-and-storage"
    }
    suffix = "001"
    aca_environment_sku = "Consumption"
    # Missing aca_environment_subnet_id
    cosmos_db_sku = "Standard"
    vnet_core_subnet_id = "/subscriptions/test-sub/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/core-subnet"
  }

  expect_failures = [
    var.aca_environment_subnet_id,
  ]
}

run "test_missing_vnet_core_subnet_id" {
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
    # Missing vnet_core_subnet_id
  }

  expect_failures = [
    var.vnet_core_subnet_id,
  ]
}
