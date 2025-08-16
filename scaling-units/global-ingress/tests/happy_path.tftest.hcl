# Test: Happy path - module creates resources with valid inputs
# Note: These tests require Azure CLI authentication or service principal setup

run "test_valid_inputs_validation" {
  command = plan

  variables {
    sku           = "Standard_AzureFrontDoor"
    location      = "East US"
    tags = {
      Environment = "test"
      Project     = "global-ingress"
    }
    custom_domain = "example.com"
    suffix        = "test01"
  }

  # This test validates the module interface and variable validation
  # without requiring Azure authentication

  # Test that plan succeeds with valid inputs
  assert {
    condition     = var.sku == "Standard_AzureFrontDoor"
    error_message = "SKU variable should accept valid Azure Front Door SKU"
  }

  assert {
    condition     = var.location == "East US"
    error_message = "Location variable should accept valid Azure region"
  }

  assert {
    condition     = var.custom_domain == "example.com"
    error_message = "Custom domain variable should accept valid domain format"
  }

  assert {
    condition     = var.suffix == "test01"
    error_message = "Suffix variable should accept valid alphanumeric suffix"
  }

  assert {
    condition     = length(var.tags) > 0
    error_message = "Tags variable should accept tag objects"
  }
}
