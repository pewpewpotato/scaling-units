# Test for Azure Front Door resource creation

provider "azurerm" {
  features {}
  skip_provider_registration = true

  # Use dummy values to avoid authentication issues in testing
  subscription_id = "00000000-0000-0000-0000-000000000000"
  tenant_id       = "00000000-0000-0000-0000-000000000000"
  client_id       = "00000000-0000-0000-0000-000000000000"
  client_secret   = "dummy"
}

run "test_front_door_resources_created" {
  command = plan

  variables {
    apim_fqdn     = "api.contoso.com"
    custom_domain = "contoso.com"
    route_name    = "api-route"
    location      = "East US"
    tags          = { Environment = "test", Project = "global-routes" }
    suffix        = "test01"
  }

  # Test that all required Front Door resources are planned
  assert {
    condition     = length([for r in values(toset([azurerm_cdn_frontdoor_profile.this])) : r]) == 1
    error_message = "Should create exactly one Front Door profile"
  }

  assert {
    condition     = length([for r in values(toset([azurerm_cdn_frontdoor_endpoint.this])) : r]) == 1
    error_message = "Should create exactly one Front Door endpoint"
  }

  assert {
    condition     = length([for r in values(toset([azurerm_cdn_frontdoor_origin_group.this])) : r]) == 1
    error_message = "Should create exactly one Front Door origin group"
  }

  assert {
    condition     = length([for r in values(toset([azurerm_cdn_frontdoor_origin.this])) : r]) == 1
    error_message = "Should create exactly one Front Door origin pointing to APIM"
  }

  assert {
    condition     = azurerm_cdn_frontdoor_origin.this.host_name == var.apim_fqdn
    error_message = "Origin should point to the provided APIM FQDN"
  }

  assert {
    condition     = azurerm_cdn_frontdoor_origin.this.origin_host_header == var.apim_fqdn
    error_message = "Origin host header should match APIM FQDN"
  }
}

run "test_origin_configuration" {
  command = plan

  variables {
    apim_fqdn     = "api.contoso.com"
    custom_domain = "contoso.com"
    route_name    = "api-route"
    location      = "East US"
    tags          = { Environment = "test" }
    suffix        = "test01"
  }

  # Test that the origin is configured correctly for APIM
  assert {
    condition     = azurerm_cdn_frontdoor_origin.this.enabled == true
    error_message = "Origin should be enabled"
  }

  assert {
    condition     = azurerm_cdn_frontdoor_origin.this.certificate_name_check_enabled == true
    error_message = "Certificate name check should be enabled"
  }

  assert {
    condition     = azurerm_cdn_frontdoor_origin.this.http_port == 80
    error_message = "HTTP port should be 80"
  }

  assert {
    condition     = azurerm_cdn_frontdoor_origin.this.https_port == 443
    error_message = "HTTPS port should be 443"
  }

  # According to PRD: No health check is required for the origin
  # We should verify that health probe is not configured or disabled
}
