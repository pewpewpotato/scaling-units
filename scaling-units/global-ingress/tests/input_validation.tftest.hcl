# Test for module interface validation

provider "azurerm" {
  features {}
  skip_provider_registration = true
}

run "valid_inputs" {
  command = plan

  variables {
    sku           = "Standard_AzureFrontDoor"
    location      = "eastus"
    tags = {
      environment = "test"
      project     = "global-ingress"
    }
    custom_domain = "example.com"
    suffix        = "test"
  }

  # Verify that the module accepts valid inputs without error
  assert {
    condition     = azurerm_resource_group.main.name != null
    error_message = "Resource group should be created with valid inputs"
  }

  assert {
    condition     = azurerm_cdn_frontdoor_profile.main.name != null
    error_message = "CDN profile should be created with valid inputs"
  }
}

# Test invalid custom domain
run "invalid_custom_domain" {
  command = plan

  variables {
    sku           = "Standard_AzureFrontDoor"
    location      = "eastus"
    tags = {
      environment = "test"
    }
    custom_domain = "invalid-domain"
    suffix        = "test"
  }

  expect_failures = [
    var.custom_domain,
  ]
}

# Test missing required inputs
run "missing_sku" {
  command = plan

  variables {
    location      = "eastus"
    tags = {
      environment = "test"
    }
    custom_domain = "example.com"
    suffix        = "test"
  }

  expect_failures = [
    var.sku,
  ]
}
