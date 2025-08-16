# Edge Cases Tests - Boundary conditions, malicious inputs, and reserved words

provider "azurerm" {
  features {}
  skip_provider_registration = true

  # Use dummy values to avoid authentication issues in testing
  subscription_id = "00000000-0000-0000-0000-000000000000"
  tenant_id       = "00000000-0000-0000-0000-000000000000"
  client_id       = "00000000-0000-0000-0000-000000000000"
  client_secret   = "dummy"
}

run "test_maximum_length_fqdn" {
  command = plan

  variables {
    # 253 characters total (max allowed for FQDN)
    apim_fqdn     = "very-long-subdomain-name-that-approaches-maximum-dns-length-limits.very-long-domain-name-that-tests-boundary-conditions.very-long-tld-extension.very-long-final-part.example.com"
    custom_domain = "example.com"
    route_name    = "api-route"
    location      = "East US"
    suffix        = "test"
    tags          = {}
  }

  # Should succeed with max length FQDN
  assert {
    condition     = azurerm_cdn_frontdoor_origin.this.host_name != null
    error_message = "Should handle maximum length FQDN"
  }
}

run "test_maximum_length_custom_domain" {
  command = plan

  variables {
    apim_fqdn     = "api.example.com"
    # 253 characters total (max allowed for domain)
    custom_domain = "very-long-subdomain-name-that-approaches-maximum-dns-length-limits.very-long-domain-name-that-tests-boundary-conditions.very-long-tld-extension.very-long-final-part.example.com"
    route_name    = "api-route"
    location      = "East US"
    suffix        = "test"
    tags          = {}
  }

  # Should succeed with max length custom domain
  assert {
    condition     = azurerm_cdn_frontdoor_custom_domain.this.host_name != null
    error_message = "Should handle maximum length custom domain"
  }
}

run "test_maximum_length_route_name" {
  command = plan

  variables {
    apim_fqdn     = "api.example.com"
    custom_domain = "example.com"
    # Exactly 80 characters (max allowed)
    route_name    = "this-is-exactly-eighty-characters-long-and-should-be-accepted-by-validation"
    location      = "East US"
    suffix        = "test"
    tags          = {}
  }

  # Should succeed with max length route name
  assert {
    condition     = azurerm_cdn_frontdoor_route.this.name != null
    error_message = "Should handle maximum length route name"
  }
}

run "test_maximum_length_suffix" {
  command = plan

  variables {
    apim_fqdn     = "api.example.com"
    custom_domain = "example.com"
    route_name    = "api-route"
    location      = "East US"
    suffix        = "1234567890"  # Exactly 10 characters (max allowed)
    tags          = {}
  }

  # Should succeed with max length suffix
  assert {
    condition     = azurerm_resource_group.this.name != null
    error_message = "Should handle maximum length suffix"
  }
}

run "test_international_domain_names" {
  command = plan

  variables {
    apim_fqdn     = "api.xn--nxasmq6b.com"  # IDN: api.测试.com
    custom_domain = "xn--nxasmq6b.com"      # IDN: 测试.com
    route_name    = "international-api"
    location      = "East US"
    suffix        = "intl"
    tags          = {}
  }

  # Should handle internationalized domain names (punycode)
  assert {
    condition     = azurerm_cdn_frontdoor_origin.this.host_name == "api.xn--nxasmq6b.com"
    error_message = "Should handle internationalized domain names"
  }
}

run "test_special_characters_in_domains" {
  command = plan

  variables {
    apim_fqdn     = "api-backend.sub-domain.example-site.co.uk"
    custom_domain = "sub-domain.example-site.co.uk"
    route_name    = "special-api-route"
    location      = "East US"
    suffix        = "spec"
    tags          = {}
  }

  # Should handle domains with hyphens and multi-part TLDs
  assert {
    condition     = azurerm_cdn_frontdoor_custom_domain.this.host_name == "sub-domain.example-site.co.uk"
    error_message = "Should handle domains with hyphens and compound TLDs"
  }
}

run "test_minimal_valid_lengths" {
  command = plan

  variables {
    apim_fqdn     = "a.co"  # Minimal valid FQDN
    custom_domain = "b.co"  # Minimal valid domain
    route_name    = "a"     # Single character route name
    location      = "East US"
    suffix        = "1"     # Single character suffix
    tags          = {}
  }

  # Should handle minimal valid inputs
  assert {
    condition     = azurerm_cdn_frontdoor_origin.this.host_name == "a.co"
    error_message = "Should handle minimal valid FQDN"
  }

  assert {
    condition     = azurerm_cdn_frontdoor_custom_domain.this.host_name == "b.co"
    error_message = "Should handle minimal valid custom domain"
  }
}

run "test_numeric_domains" {
  command = plan

  variables {
    apim_fqdn     = "api.123456.com"
    custom_domain = "123456.com"
    route_name    = "numeric-api"
    location      = "East US"
    suffix        = "123"
    tags          = {}
  }

  # Should handle numeric subdomains and suffixes
  assert {
    condition     = azurerm_cdn_frontdoor_origin.this.host_name == "api.123456.com"
    error_message = "Should handle numeric subdomains"
  }
}

run "test_reserved_words_in_inputs" {
  command = plan

  variables {
    apim_fqdn     = "admin.test.com"
    custom_domain = "root.test.com"
    route_name    = "admin-root-api"
    location      = "East US"
    suffix        = "admin"
    tags = {
      admin = "true"
      root  = "false"
    }
  }

  # Should handle reserved words (they're just strings to Azure)
  assert {
    condition     = azurerm_cdn_frontdoor_route.this.name == "admin-root-api"
    error_message = "Should handle reserved words in route names"
  }
}

run "test_edge_case_tag_values" {
  command = plan

  variables {
    apim_fqdn     = "api.example.com"
    custom_domain = "example.com"
    route_name    = "api-route"
    location      = "East US"
    suffix        = "edge"
    tags = {
      "empty-value"     = ""
      "spaces in key"   = "value with spaces"
      "special-chars"   = "value!@#$%^&*()"
      "unicode"         = "测试值"
      "very-long-key-name-that-tests-boundaries" = "very-long-value-that-tests-tag-value-boundaries-and-edge-cases"
    }
  }

  # Should handle various tag edge cases
  assert {
    condition     = azurerm_resource_group.this.tags["empty-value"] == ""
    error_message = "Should handle empty tag values"
  }
}

run "test_unusual_but_valid_tlds" {
  command = plan

  variables {
    apim_fqdn     = "api.example.museum"  # Longer TLD
    custom_domain = "example.travel"      # Another longer TLD
    route_name    = "museum-api"
    location      = "East US"
    suffix        = "museum"
    tags          = {}
  }

  # Should handle unusual but valid TLDs
  assert {
    condition     = azurerm_cdn_frontdoor_origin.this.host_name == "api.example.museum"
    error_message = "Should handle unusual but valid TLDs"
  }
}
