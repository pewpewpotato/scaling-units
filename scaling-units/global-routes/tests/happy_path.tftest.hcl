# Happy Path Tests - Valid inputs and successful provisioning

provider "azurerm" {
  features {}
  skip_provider_registration = true

  # Use dummy values to avoid authentication issues in testing
  subscription_id = "00000000-0000-0000-0000-000000000000"
  tenant_id       = "00000000-0000-0000-0000-000000000000"
  client_id       = "00000000-0000-0000-0000-000000000000"
  client_secret   = "dummy"
}

run "test_standard_configuration" {
  command = plan

  variables {
    apim_fqdn     = "api.contoso.com"
    custom_domain = "contoso.com"
    route_name    = "main-api"
    location      = "East US"
    suffix        = "prod01"
    tags = {
      Environment = "production"
      Project     = "api-gateway"
    }
  }

  # Verify all resources are planned for creation
  assert {
    condition     = azurerm_resource_group.this != null
    error_message = "Resource group should be planned for creation"
  }

  assert {
    condition     = azurerm_cdn_frontdoor_profile.this != null
    error_message = "Front Door profile should be planned for creation"
  }

  assert {
    condition     = azurerm_cdn_frontdoor_endpoint.this != null
    error_message = "Front Door endpoint should be planned for creation"
  }

  assert {
    condition     = azurerm_cdn_frontdoor_origin_group.this != null
    error_message = "Front Door origin group should be planned for creation"
  }

  assert {
    condition     = azurerm_cdn_frontdoor_origin.this != null
    error_message = "Front Door origin should be planned for creation"
  }

  assert {
    condition     = azurerm_cdn_frontdoor_custom_domain.this != null
    error_message = "Front Door custom domain should be planned for creation"
  }

  assert {
    condition     = azurerm_cdn_frontdoor_route.this != null
    error_message = "Front Door route should be planned for creation"
  }

  # Verify configuration values are correctly applied
  assert {
    condition     = azurerm_cdn_frontdoor_origin.this.host_name == "api.contoso.com"
    error_message = "Origin should point to the correct APIM FQDN"
  }

  assert {
    condition     = azurerm_cdn_frontdoor_custom_domain.this.host_name == "contoso.com"
    error_message = "Custom domain should use the provided domain"
  }

  assert {
    condition     = azurerm_cdn_frontdoor_route.this.name == "main-api"
    error_message = "Route should use the provided route name"
  }

  assert {
    condition     = azurerm_resource_group.this.location == "East US"
    error_message = "Resource group should be in the specified location"
  }
}

run "test_minimal_valid_configuration" {
  command = plan

  variables {
    apim_fqdn     = "api.example.org"
    custom_domain = "example.org"
    route_name    = "api"
    location      = "West US"
    suffix        = "min"
    tags          = {}
  }

  # Test with minimal valid inputs (empty tags)
  assert {
    condition     = azurerm_resource_group.this.tags != null
    error_message = "Tags should be set even when empty"
  }

  assert {
    condition     = length(azurerm_cdn_frontdoor_route.this.name) > 0
    error_message = "Route name should be set and non-empty"
  }

  assert {
    condition     = azurerm_cdn_frontdoor_origin.this.enabled == true
    error_message = "Origin should be enabled by default"
  }
}

run "test_complex_valid_configuration" {
  command = plan

  variables {
    apim_fqdn     = "api-backend.enterprise.example.com"
    custom_domain = "api.enterprise.example.com"
    route_name    = "enterprise-api-v2"
    location      = "West Europe"
    suffix        = "prod99"
    tags = {
      Environment   = "production"
      Project       = "enterprise-api"
      Team          = "platform"
      CostCenter    = "engineering"
      Owner         = "platform-team"
      BusinessUnit  = "technology"
    }
  }

  # Test with complex but valid inputs
  assert {
    condition     = azurerm_cdn_frontdoor_profile.this.sku_name == "Standard_AzureFrontDoor"
    error_message = "Should use Standard SKU for Front Door"
  }

  assert {
    condition     = azurerm_cdn_frontdoor_route.this.forwarding_protocol == "HttpsOnly"
    error_message = "Should enforce HTTPS-only forwarding"
  }

  assert {
    condition     = azurerm_cdn_frontdoor_route.this.https_redirect_enabled == true
    error_message = "Should enable HTTPS redirect"
  }

  assert {
    condition     = azurerm_cdn_frontdoor_custom_domain.this.tls[0].minimum_tls_version == "TLS12"
    error_message = "Should enforce minimum TLS 1.2"
  }

  assert {
    condition     = azurerm_cdn_frontdoor_origin.this.certificate_name_check_enabled == true
    error_message = "Should enable certificate name check for security"
  }
}
