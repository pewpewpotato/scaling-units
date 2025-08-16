# Test for Environment Compute and Storage Module - Private DNS Zone Tests

provider "azurerm" {
  features {}
  skip_provider_registration = true
}

run "test_cosmos_db_private_dns_zone_created_and_linked" {
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
    condition     = azurerm_private_dns_zone.cosmos_db.name == "privatelink.documents.azure.com"
    error_message = "Private DNS zone should be created for Cosmos DB"
  }

  assert {
    condition     = length(azurerm_private_dns_zone_virtual_network_link.cosmos_db) > 0
    error_message = "Private DNS zone should be linked to the VNET"
  }
}

run "test_cosmos_db_public_access_disabled" {
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
    condition     = azurerm_cosmosdb_account.this.public_network_access_enabled == false
    error_message = "Cosmos DB public network access should be disabled for security"
  }
}
