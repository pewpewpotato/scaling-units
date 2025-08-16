# Test for basic module structure and interface

provider "azurerm" {
  features {}
  skip_provider_registration = true

  # Use dummy values to avoid authentication issues in testing
  subscription_id = "00000000-0000-0000-0000-000000000000"
  tenant_id       = "00000000-0000-0000-0000-000000000000"
  client_id       = "00000000-0000-0000-0000-000000000000"
  client_secret   = "dummy"
}

run "test_basic_module_structure" {
  command = plan

  variables {
    apim_fqdn     = "api.example.com"
    custom_domain = "example.com"
    route_name    = "test-route"
    location      = "East US"
    tags          = { Environment = "test" }
    suffix        = "test"
  }

  # This test will pass once we have the basic module structure
  # It's mainly checking that the plan works with valid inputs
}
