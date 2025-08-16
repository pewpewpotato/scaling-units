# Test: Variable validation without Azure provider
# These tests validate input validation logic using OpenTofu validate command

run "valid_standard_sku" {
  command = plan

  variables {
    sku           = "Standard_AzureFrontDoor"
    location      = "East US"
    tags = {
      Environment = "test"
    }
    custom_domain = "example.com"
    suffix        = "test01"
  }

  # Test should succeed with valid Standard SKU
}

run "valid_premium_sku" {
  command = plan

  variables {
    sku           = "Premium_AzureFrontDoor"
    location      = "West US"
    tags = {
      Environment = "prod"
    }
    custom_domain = "prod.example.com"
    suffix        = "prod"
  }

  # Test should succeed with valid Premium SKU
}

run "invalid_sku_should_fail" {
  command = plan

  variables {
    sku           = "InvalidSKU"
    location      = "East US"
    tags = {
      Environment = "test"
    }
    custom_domain = "example.com"
    suffix        = "test"
  }

  expect_failures = [
    var.sku,
  ]
}

run "invalid_custom_domain_should_fail" {
  command = plan

  variables {
    sku           = "Standard_AzureFrontDoor"
    location      = "East US"
    tags = {
      Environment = "test"
    }
    custom_domain = "invalid-domain-format"
    suffix        = "test"
  }

  expect_failures = [
    var.custom_domain,
  ]
}

run "invalid_suffix_too_long_should_fail" {
  command = plan

  variables {
    sku           = "Standard_AzureFrontDoor"
    location      = "East US"
    tags = {
      Environment = "test"
    }
    custom_domain = "example.com"
    suffix        = "thisistoolongtobevalid"
  }

  expect_failures = [
    var.suffix,
  ]
}

run "invalid_suffix_special_chars_should_fail" {
  command = plan

  variables {
    sku           = "Standard_AzureFrontDoor"
    location      = "East US"
    tags = {
      Environment = "test"
    }
    custom_domain = "example.com"
    suffix        = "test-123!"
  }

  expect_failures = [
    var.suffix,
  ]
}
