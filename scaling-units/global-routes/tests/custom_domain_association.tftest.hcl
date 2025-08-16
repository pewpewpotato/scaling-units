# Test for custom domain association with Front Door route

provider "azurerm" {
  features {}
  skip_provider_registration = true

  # Use dummy values to avoid authentication issues in testing
  subscription_id = "00000000-0000-0000-0000-000000000000"
  tenant_id       = "00000000-0000-0000-0000-000000000000"
  client_id       = "00000000-0000-0000-0000-000000000000"
  client_secret   = "dummy"
}

run "test_custom_domain_association" {
  command = plan

  variables {
    apim_fqdn     = "api.contoso.com"
    custom_domain = "api.example.org"
    route_name    = "api-route"
    location      = "East US"
    tags          = { Environment = "test" }
    suffix        = "test01"
  }

  # Test that custom domain is created and configured correctly
  assert {
    condition     = azurerm_cdn_frontdoor_custom_domain.this.host_name == var.custom_domain
    error_message = "Custom domain hostname should match the provided custom domain variable"
  }

  assert {
    condition     = azurerm_cdn_frontdoor_custom_domain.this.tls[0].certificate_type == "ManagedCertificate"
    error_message = "Custom domain should use managed certificate"
  }

  assert {
    condition     = azurerm_cdn_frontdoor_custom_domain.this.tls[0].minimum_tls_version == "TLS12"
    error_message = "Custom domain should enforce minimum TLS 1.2"
  }

  # Test that the route is associated with the custom domain
  assert {
    condition     = contains(azurerm_cdn_frontdoor_route.this.cdn_frontdoor_custom_domain_ids, azurerm_cdn_frontdoor_custom_domain.this.id)
    error_message = "Route should be associated with the custom domain"
  }

  # Test that the route is properly configured
  assert {
    condition     = azurerm_cdn_frontdoor_route.this.forwarding_protocol == "HttpsOnly"
    error_message = "Route should enforce HTTPS only"
  }

  assert {
    condition     = azurerm_cdn_frontdoor_route.this.https_redirect_enabled == true
    error_message = "Route should have HTTPS redirect enabled"
  }
}

run "test_different_custom_domains" {
  command = plan

  variables {
    apim_fqdn     = "api-backend.example.com"
    custom_domain = "www.mysite.com"
    route_name    = "main-route"
    location      = "West US"
    tags          = { Environment = "production" }
    suffix        = "prod"
  }

  # Test with different domain names
  assert {
    condition     = azurerm_cdn_frontdoor_custom_domain.this.host_name == var.custom_domain
    error_message = "Custom domain should match input regardless of the specific domain"
  }

  assert {
    condition     = azurerm_cdn_frontdoor_origin.this.host_name == var.apim_fqdn
    error_message = "Origin should point to APIM FQDN regardless of custom domain"
  }
}
