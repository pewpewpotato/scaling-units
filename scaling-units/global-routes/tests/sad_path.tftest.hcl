# Sad Path Tests - Invalid inputs and validation errors

provider "azurerm" {
  features {}
  skip_provider_registration = true

  # Use dummy values to avoid authentication issues in testing
  subscription_id = "00000000-0000-0000-0000-000000000000"
  tenant_id       = "00000000-0000-0000-0000-000000000000"
  client_id       = "00000000-0000-0000-0000-000000000000"
  client_secret   = "dummy"
}

run "test_missing_apim_fqdn" {
  command = plan

  variables {
    apim_fqdn     = ""  # Empty APIM FQDN should fail
    custom_domain = "example.com"
    route_name    = "api-route"
    location      = "East US"
    suffix        = "test"
    tags          = {}
  }

  expect_failures = [
    var.apim_fqdn
  ]
}

run "test_invalid_apim_fqdn_no_tld" {
  command = plan

  variables {
    apim_fqdn     = "api-backend"  # No TLD should fail
    custom_domain = "example.com"
    route_name    = "api-route"
    location      = "East US"
    suffix        = "test"
    tags          = {}
  }

  expect_failures = [
    var.apim_fqdn
  ]
}

run "test_invalid_apim_fqdn_leading_dot" {
  command = plan

  variables {
    apim_fqdn     = ".api.example.com"  # Leading dot should fail
    custom_domain = "example.com"
    route_name    = "api-route"
    location      = "East US"
    suffix        = "test"
    tags          = {}
  }

  expect_failures = [
    var.apim_fqdn
  ]
}

run "test_invalid_apim_fqdn_trailing_dot" {
  command = plan

  variables {
    apim_fqdn     = "api.example.com."  # Trailing dot should fail
    custom_domain = "example.com"
    route_name    = "api-route"
    location      = "East US"
    suffix        = "test"
    tags          = {}
  }

  expect_failures = [
    var.apim_fqdn
  ]
}

run "test_missing_custom_domain" {
  command = plan

  variables {
    apim_fqdn     = "api.example.com"
    custom_domain = ""  # Empty custom domain should fail
    route_name    = "api-route"
    location      = "East US"
    suffix        = "test"
    tags          = {}
  }

  expect_failures = [
    var.custom_domain
  ]
}

run "test_invalid_custom_domain_no_tld" {
  command = plan

  variables {
    apim_fqdn     = "api.example.com"
    custom_domain = "example"  # No TLD should fail
    route_name    = "api-route"
    location      = "East US"
    suffix        = "test"
    tags          = {}
  }

  expect_failures = [
    var.custom_domain
  ]
}

run "test_missing_route_name" {
  command = plan

  variables {
    apim_fqdn     = "api.example.com"
    custom_domain = "example.com"
    route_name    = ""  # Empty route name should fail
    location      = "East US"
    suffix        = "test"
    tags          = {}
  }

  expect_failures = [
    var.route_name
  ]
}

run "test_invalid_route_name_leading_hyphen" {
  command = plan

  variables {
    apim_fqdn     = "api.example.com"
    custom_domain = "example.com"
    route_name    = "-invalid-route"  # Leading hyphen should fail
    location      = "East US"
    suffix        = "test"
    tags          = {}
  }

  expect_failures = [
    var.route_name
  ]
}

run "test_invalid_route_name_trailing_hyphen" {
  command = plan

  variables {
    apim_fqdn     = "api.example.com"
    custom_domain = "example.com"
    route_name    = "invalid-route-"  # Trailing hyphen should fail
    location      = "East US"
    suffix        = "test"
    tags          = {}
  }

  expect_failures = [
    var.route_name
  ]
}

run "test_route_name_too_long" {
  command = plan

  variables {
    apim_fqdn     = "api.example.com"
    custom_domain = "example.com"
    route_name    = "this-is-a-very-long-route-name-that-exceeds-the-maximum-allowed-length-of-80-characters-and-should-fail"  # > 80 chars
    location      = "East US"
    suffix        = "test"
    tags          = {}
  }

  expect_failures = [
    var.route_name
  ]
}

run "test_missing_location" {
  command = plan

  variables {
    apim_fqdn     = "api.example.com"
    custom_domain = "example.com"
    route_name    = "api-route"
    location      = ""  # Empty location should fail
    suffix        = "test"
    tags          = {}
  }

  expect_failures = [
    var.location
  ]
}

run "test_missing_suffix" {
  command = plan

  variables {
    apim_fqdn     = "api.example.com"
    custom_domain = "example.com"
    route_name    = "api-route"
    location      = "East US"
    suffix        = ""  # Empty suffix should fail
    tags          = {}
  }

  expect_failures = [
    var.suffix
  ]
}

run "test_suffix_too_long" {
  command = plan

  variables {
    apim_fqdn     = "api.example.com"
    custom_domain = "example.com"
    route_name    = "api-route"
    location      = "East US"
    suffix        = "suffix-too-long"  # > 10 chars should fail
    tags          = {}
  }

  expect_failures = [
    var.suffix
  ]
}

run "test_suffix_with_special_chars" {
  command = plan

  variables {
    apim_fqdn     = "api.example.com"
    custom_domain = "example.com"
    route_name    = "api-route"
    location      = "East US"
    suffix        = "test-01"  # Hyphen should fail (alphanumeric only)
    tags          = {}
  }

  expect_failures = [
    var.suffix
  ]
}
