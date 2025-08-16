# Test for Environment Compute and Storage Module - NSG Rules Tests

provider "azurerm" {
  features {}
  skip_provider_registration = true
}

run "test_nsg_rules_created_for_aca_and_cosmos_db" {
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
    vnet_id = "/subscriptions/test-sub/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet"
  }

  assert {
    condition     = length(azurerm_network_security_group.aca_environment) > 0
    error_message = "NSG should be created for ACA Environment"
  }

  assert {
    condition     = length(azurerm_network_security_group.cosmos_db) > 0
    error_message = "NSG should be created for Cosmos DB"
  }

  assert {
    condition     = length(azurerm_subnet_network_security_group_association.aca_environment) > 0
    error_message = "NSG should be associated with ACA Environment subnet"
  }

  assert {
    condition     = length(azurerm_subnet_network_security_group_association.cosmos_db) > 0
    error_message = "NSG should be associated with Cosmos DB subnet"
  }
}
