provider "azurerm" {
  features {}
  skip_provider_registration = true
}

run "test_all_required_outputs_exist" {
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

  # Test that all required outputs are available
  assert {
    condition     = output.apim_id != null
    error_message = "apim_id output should be available"
  }

  assert {
    condition     = output.apim_name != null
    error_message = "apim_name output should be available"
  }

  assert {
    condition     = output.subnet_id != null
    error_message = "subnet_id output should be available"
  }

  assert {
    condition     = output.resource_group_name != null
    error_message = "resource_group_name output should be available"
  }

  # Test additional outputs that would be useful for consumers
  assert {
    condition     = output.apim_gateway_url != null
    error_message = "apim_gateway_url output should be available for API consumers"
  }

  assert {
    condition     = output.apim_management_api_url != null
    error_message = "apim_management_api_url output should be available for management"
  }

  assert {
    condition     = output.subnet_name != null
    error_message = "subnet_name output should be available"
  }
}
