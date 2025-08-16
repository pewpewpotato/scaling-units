# Test for input validation

provider "azurerm" {
  features {}
  skip_provider_registration = true

  # Use dummy values to avoid authentication issues in testing
  subscription_id = "00000000-0000-0000-0000-000000000000"
  tenant_id       = "00000000-0000-0000-0000-000000000000"
  client_id       = "00000000-0000-0000-0000-000000000000"
  client_secret   = "dummy"
}

run "test_invalid_apim_fqdn_fails" {
  command = plan

  variables {
    apim_fqdn     = "invalid-fqdn"  # Invalid FQDN without TLD
    custom_domain = "example.com"
    route_name    = "test-route"
    location      = "East US"
    tags          = { Environment = "test" }
    suffix        = "test"
  }

  expect_failures = [
    var.apim_fqdn
  ]
}

run "test_invalid_custom_domain_fails" {
  command = plan

  variables {
    apim_fqdn     = "api.example.com"
    custom_domain = "invalid-domain"  # Invalid domain without TLD
    route_name    = "test-route"
    location      = "East US"
    tags          = { Environment = "test" }
    suffix        = "test"
  }

  expect_failures = [
    var.custom_domain
  ]
}

run "test_empty_route_name_fails" {
  command = plan

  variables {
    apim_fqdn     = "api.example.com"
    custom_domain = "example.com"
    route_name    = ""  # Empty route name should fail
    location      = "East US"
    tags          = { Environment = "test" }
    suffix        = "test"
  }

  expect_failures = [
    var.route_name
  ]
}

run "test_invalid_suffix_fails" {
  command = plan

  variables {
    apim_fqdn     = "api.example.com"
    custom_domain = "example.com"
    route_name    = "test-route"
    location      = "East US"
    tags          = { Environment = "test" }
    suffix        = "test-suffix-too-long"  # Suffix longer than 10 chars should fail
  }

  expect_failures = [
    var.suffix
  ]
}
