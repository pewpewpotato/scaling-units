# Test for Environment Compute and Storage Module - VNET ID Validation Tests

provider "azurerm" {
  features {}
  skip_provider_registration = true
}

run "test_empty_vnet_id" {
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
    vnet_id = ""
  }

  expect_failures = [
    var.vnet_id,
  ]
}

run "test_invalid_vnet_id_format" {
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
    vnet_id = "invalid-vnet-id"
  }

  expect_failures = [
    var.vnet_id,
  ]
}
