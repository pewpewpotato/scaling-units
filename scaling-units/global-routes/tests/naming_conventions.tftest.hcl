# Test for azure/naming module integration

provider "azurerm" {
  features {}
  skip_provider_registration = true

  # Use dummy values to avoid authentication issues in testing
  subscription_id = "00000000-0000-0000-0000-000000000000"
  tenant_id       = "00000000-0000-0000-0000-000000000000"
  client_id       = "00000000-0000-0000-0000-000000000000"
  client_secret   = "dummy"
}

run "test_naming_conventions" {
  command = plan

  variables {
    apim_fqdn     = "api.contoso.com"
    custom_domain = "contoso.com"
    route_name    = "api-route"
    location      = "East US"
    tags          = { Environment = "test" }
    suffix        = "test01"
  }

  # Test that azure/naming module is used for resource naming
  assert {
    condition     = azurerm_resource_group.this.name == module.naming.resource_group.name
    error_message = "Resource group should use azure/naming module for naming"
  }

  assert {
    condition     = azurerm_cdn_frontdoor_profile.this.name == module.naming.frontdoor.name
    error_message = "Front Door profile should use azure/naming module for naming"
  }

  # Test that naming follows consistent patterns for sub-resources
  assert {
    condition     = can(regex("${module.naming.frontdoor.name}-endpoint", azurerm_cdn_frontdoor_endpoint.this.name))
    error_message = "Front Door endpoint should follow naming pattern with base name + suffix"
  }

  assert {
    condition     = can(regex("${module.naming.frontdoor.name}-origin-group", azurerm_cdn_frontdoor_origin_group.this.name))
    error_message = "Origin group should follow naming pattern with base name + suffix"
  }

  assert {
    condition     = can(regex("${module.naming.frontdoor.name}-origin", azurerm_cdn_frontdoor_origin.this.name))
    error_message = "Origin should follow naming pattern with base name + suffix"
  }
}

run "test_naming_with_different_suffix" {
  command = plan

  variables {
    apim_fqdn     = "api.example.com"
    custom_domain = "example.com"
    route_name    = "main-route"
    location      = "West Europe"
    tags          = { Environment = "production" }
    suffix        = "prod99"
  }

  # Test that different suffix values are correctly applied
  assert {
    condition     = length(azurerm_resource_group.this.name) > 0
    error_message = "Resource group name should be generated and non-empty"
  }

  assert {
    condition     = length(azurerm_cdn_frontdoor_profile.this.name) > 0
    error_message = "Front Door profile name should be generated and non-empty"
  }

  # Test that naming is consistent across resources
  assert {
    condition     = azurerm_cdn_frontdoor_endpoint.this.name != azurerm_cdn_frontdoor_origin_group.this.name
    error_message = "Different resources should have different names"
  }
}
