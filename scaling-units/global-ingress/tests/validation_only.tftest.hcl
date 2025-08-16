# Test for input validation logic only (no Azure provider required)

run "valid_custom_domain" {
  command = plan

  variables {
    sku           = "Standard_AzureFrontDoor"
    location      = "eastus"
    tags = {
      environment = "test"
    }
    custom_domain = "example.com"
    suffix        = "test"
  }

  # This test should pass validation without errors
}

run "invalid_custom_domain_no_tld" {
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

run "invalid_sku" {
  command = plan

  variables {
    sku           = "InvalidSKU"
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

run "invalid_suffix_too_long" {
  command = plan

  variables {
    sku           = "Standard_AzureFrontDoor"
    location      = "eastus"
    tags = {
      environment = "test"
    }
    custom_domain = "example.com"
    suffix        = "thisistoolong"
  }

  expect_failures = [
    var.suffix,
  ]
}

run "invalid_suffix_special_chars" {
  command = plan

  variables {
    sku           = "Standard_AzureFrontDoor"
    location      = "eastus"
    tags = {
      environment = "test"
    }
    custom_domain = "example.com"
    suffix        = "test-123"
  }

  expect_failures = [
    var.suffix,
  ]
}
