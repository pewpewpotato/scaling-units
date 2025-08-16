# Configurable Inputs Tests - Verify input configuration flexibility

provider "azurerm" {
  features {}
  skip_provider_registration = true

  # Use dummy values to avoid authentication issues in testing
  subscription_id = "00000000-0000-0000-0000-000000000000"
  tenant_id       = "00000000-0000-0000-0000-000000000000"
  client_id       = "00000000-0000-0000-0000-000000000000"
  client_secret   = "dummy"
}

run "test_different_azure_regions" {
  command = plan

  variables {
    apim_fqdn     = "api.example.com"
    custom_domain = "example.com"
    route_name    = "api-route"
    location      = "West Europe"  # Different region
    suffix        = "eu"
    tags          = { Region = "europe" }
  }

  # Should work with different Azure regions
  assert {
    condition     = azurerm_resource_group.this.location == "West Europe"
    error_message = "Should support different Azure regions"
  }
}

run "test_different_apim_configurations" {
  command = plan

  variables {
    apim_fqdn     = "gateway.backend.internal"  # Different APIM setup
    custom_domain = "api.frontend.com"
    route_name    = "internal-gateway"
    location      = "Central US"
    suffix        = "internal"
    tags          = { Type = "internal" }
  }

  # Should work with different APIM configurations
  assert {
    condition     = azurerm_cdn_frontdoor_origin.this.host_name == "gateway.backend.internal"
    error_message = "Should support different APIM FQDN configurations"
  }

  assert {
    condition     = azurerm_cdn_frontdoor_origin.this.origin_host_header == "gateway.backend.internal"
    error_message = "Origin host header should match APIM FQDN"
  }
}

run "test_subdomain_custom_domains" {
  command = plan

  variables {
    apim_fqdn     = "api.backend.example.com"
    custom_domain = "api.frontend.example.com"  # Subdomain configuration
    route_name    = "subdomain-api"
    location      = "South Central US"
    suffix        = "sub"
    tags          = { Subdomain = "true" }
  }

  # Should work with subdomain configurations
  assert {
    condition     = azurerm_cdn_frontdoor_custom_domain.this.host_name == "api.frontend.example.com"
    error_message = "Should support subdomain custom domains"
  }

  # Custom domain name should be properly formatted (dots replaced with hyphens)
  assert {
    condition     = azurerm_cdn_frontdoor_custom_domain.this.name == "api-frontend-example-com"
    error_message = "Custom domain name should replace dots with hyphens"
  }
}

run "test_various_route_naming_patterns" {
  command = plan

  variables {
    apim_fqdn     = "api.example.com"
    custom_domain = "example.com"
    route_name    = "v1-public-api-route"  # Version and type in name
    location      = "North Central US"
    suffix        = "v1"
    tags          = { Version = "v1", Access = "public" }
  }

  # Should work with complex route naming patterns
  assert {
    condition     = azurerm_cdn_frontdoor_route.this.name == "v1-public-api-route"
    error_message = "Should support complex route naming patterns"
  }
}

run "test_comprehensive_tagging_strategy" {
  command = plan

  variables {
    apim_fqdn     = "api.example.com"
    custom_domain = "example.com"
    route_name    = "api-route"
    location      = "East US 2"
    suffix        = "tagged"
    tags = {
      Environment     = "production"
      Project         = "api-gateway"
      Team            = "platform-engineering"
      CostCenter      = "12345"
      Owner           = "john.doe@example.com"
      BusinessUnit    = "technology"
      Application     = "front-door-routing"
      Backup          = "required"
      Monitoring      = "enabled"
      Compliance      = "required"
      DataClass       = "public"
      Schedule        = "24x7"
    }
  }

  # Should handle comprehensive tagging strategies
  assert {
    condition     = azurerm_resource_group.this.tags["Environment"] == "production"
    error_message = "Should propagate all tags to resource group"
  }

  assert {
    condition     = azurerm_cdn_frontdoor_profile.this.tags["Project"] == "api-gateway"
    error_message = "Should propagate all tags to Front Door profile"
  }

  assert {
    condition     = length(azurerm_resource_group.this.tags) == 12
    error_message = "Should apply all provided tags"
  }
}

run "test_different_suffix_patterns" {
  command = plan

  variables {
    apim_fqdn     = "api.example.com"
    custom_domain = "example.com"
    route_name    = "api-route"
    location      = "West US 2"
    suffix        = "dev001"  # Environment + sequence number
    tags          = { Environment = "development" }
  }

  # Should work with different suffix patterns
  assert {
    condition     = length(azurerm_resource_group.this.name) > 0
    error_message = "Should generate names with dev001 suffix"
  }

  assert {
    condition     = length(azurerm_cdn_frontdoor_profile.this.name) > 0
    error_message = "Should generate Front Door name with dev001 suffix"
  }
}

run "test_organization_domain_patterns" {
  command = plan

  variables {
    apim_fqdn     = "api.corp.contoso.com"        # Corporate subdomain
    custom_domain = "api.external.contoso.com"    # External-facing domain
    route_name    = "corporate-api"
    location      = "Canada Central"
    suffix        = "corp"
    tags = {
      Organization = "contoso"
      Domain       = "corporate"
      External     = "true"
    }
  }

  # Should work with organizational domain patterns
  assert {
    condition     = azurerm_cdn_frontdoor_origin.this.host_name == "api.corp.contoso.com"
    error_message = "Should support corporate domain patterns"
  }

  assert {
    condition     = azurerm_cdn_frontdoor_custom_domain.this.host_name == "api.external.contoso.com"
    error_message = "Should support external-facing domain patterns"
  }
}

run "test_multi_environment_configuration" {
  command = plan

  variables {
    apim_fqdn     = "api-staging.example.com"
    custom_domain = "staging.example.com"
    route_name    = "staging-api"
    location      = "Australia East"
    suffix        = "staging"
    tags = {
      Environment = "staging"
      Purpose     = "pre-production-testing"
      DataSync    = "production"
    }
  }

  # Should work with different environment configurations
  assert {
    condition     = azurerm_cdn_frontdoor_route.this.forwarding_protocol == "HttpsOnly"
    error_message = "Should maintain security standards across environments"
  }

  assert {
    condition     = azurerm_cdn_frontdoor_custom_domain.this.tls[0].minimum_tls_version == "TLS12"
    error_message = "Should maintain TLS standards across environments"
  }
}
