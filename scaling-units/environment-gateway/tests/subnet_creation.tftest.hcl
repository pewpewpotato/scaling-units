provider "azurerm" {
  features {}
  skip_provider_registration = true
}

run "test_subnet_creation_with_valid_vnet" {
  command = plan

  variables {
    vnet_name                = "test-vnet"
    vnet_resource_group_name = "test-vnet-rg"
    nsg_name                 = "test-nsg"
    nsg_resource_group_name  = "test-nsg-rg"
    apim_subnet_prefix       = "10.0.1.0/24"
    location                 = "eastus"
    tags = {
      environment = "test"
    }
    suffix = "test"
  }

  # Test that subnet is created with correct configuration
  assert {
    condition     = azurerm_subnet.apim.name != null
    error_message = "APIM subnet should be created"
  }

  assert {
    condition     = azurerm_subnet.apim.virtual_network_name == "test-vnet"
    error_message = "Subnet should reference the correct virtual network"
  }

  assert {
    condition     = length(azurerm_subnet.apim.address_prefixes) > 0
    error_message = "Subnet should have address prefixes configured"
  }

  assert {
    condition     = contains(azurerm_subnet.apim.address_prefixes, "10.0.1.0/24")
    error_message = "Subnet should use the specified address prefix"
  }

  assert {
    condition     = contains(azurerm_subnet.apim.service_endpoints, "Microsoft.Storage")
    error_message = "Subnet should have required service endpoints for APIM"
  }
}
