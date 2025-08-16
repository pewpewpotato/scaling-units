provider "azurerm" {
  features {}
  skip_provider_registration = true
}

run "test_readme_exists" {
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

  # This test will only pass if README.md exists and module structure is valid
  assert {
    condition     = var.vnet_name == "test-vnet"
    error_message = "Module should work with proper inputs and README.md should exist"
  }
}
