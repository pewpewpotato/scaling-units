# Test: Edge cases, malicious inputs, and reserved values
# Tests for security, boundary conditions, and Azure naming constraints

run "malicious_script_in_tag_value" {
  command = plan

  variables {
    sku           = "Standard_AzureFrontDoor"
    location      = "East US"
    tags = {
      Environment = "<script>alert('xss')</script>"
      Project     = "global-ingress"
    }
    custom_domain = "example.com"
    suffix        = "test01"
  }

  expect_failures = [
    var.tags,
  ]
}

run "malicious_sql_injection_in_suffix" {
  command = plan

  variables {
    sku           = "Standard_AzureFrontDoor"
    location      = "East US"
    tags = {
      Environment = "test"
    }
    custom_domain = "example.com"
    suffix        = "'; DROP TABLE users; --"
  }

  expect_failures = [
    var.suffix,
  ]
}

run "reserved_azure_keywords_in_suffix" {
  command = plan

  variables {
    sku           = "Standard_AzureFrontDoor"
    location      = "East US"
    tags = {
      Environment = "test"
    }
    custom_domain = "example.com"
    suffix        = "microsoft"
  }

  expect_failures = [
    var.suffix,
  ]
}

run "unicode_characters_in_domain" {
  command = plan

  variables {
    sku           = "Standard_AzureFrontDoor"
    location      = "East US"
    tags = {
      Environment = "test"
    }
    custom_domain = "测试.example.com"
    suffix        = "test01"
  }

  expect_failures = [
    var.custom_domain,
  ]
}

run "extremely_long_tag_value" {
  command = plan

  variables {
    sku           = "Standard_AzureFrontDoor"
    location      = "East US"
    tags = {
      Environment = "this-is-an-extremely-long-tag-value-that-exceeds-azure-tag-limits-which-should-be-rejected-by-validation-because-azure-has-specific-limits-on-tag-lengths-and-this-exceeds-them-significantly-making-it-invalid-for-azure-resource-tagging-purposes-and-should-trigger-a-validation-error"
    }
    custom_domain = "example.com"
    suffix        = "test01"
  }

  expect_failures = [
    var.tags,
  ]
}

run "path_traversal_in_custom_domain" {
  command = plan

  variables {
    sku           = "Standard_AzureFrontDoor"
    location      = "East US"
    tags = {
      Environment = "test"
    }
    custom_domain = "../../../etc/passwd.com"
    suffix        = "test01"
  }

  expect_failures = [
    var.custom_domain,
  ]
}

run "maximum_suffix_boundary" {
  command = plan

  variables {
    sku           = "Standard_AzureFrontDoor"
    location      = "East US"
    tags = {
      Environment = "test"
    }
    custom_domain = "example.com"
    suffix        = "1234567890"  # Exactly 10 characters (max allowed)
  }

  # Should pass - exactly at boundary
}

run "minimum_suffix_boundary" {
  command = plan

  variables {
    sku           = "Standard_AzureFrontDoor"
    location      = "East US"
    tags = {
      Environment = "test"
    }
    custom_domain = "example.com"
    suffix        = "a"  # Exactly 1 character (min allowed)
  }

  # Should pass - exactly at boundary
}

run "reserved_tag_keys" {
  command = plan

  variables {
    sku           = "Standard_AzureFrontDoor"
    location      = "East US"
    tags = {
      "ms-resource-usage" = "test"  # Reserved Microsoft tag prefix
      Environment         = "test"
    }
    custom_domain = "example.com"
    suffix        = "test01"
  }

  expect_failures = [
    var.tags,
  ]
}

run "case_sensitivity_domain" {
  command = plan

  variables {
    sku           = "Standard_AzureFrontDoor"
    location      = "East US"
    tags = {
      Environment = "test"
    }
    custom_domain = "EXAMPLE.COM"
    suffix        = "test01"
  }

  # Should pass - domains are case insensitive
}

run "numeric_only_suffix" {
  command = plan

  variables {
    sku           = "Standard_AzureFrontDoor"
    location      = "East US"
    tags = {
      Environment = "test"
    }
    custom_domain = "example.com"
    suffix        = "123456"
  }

  # Should pass - numeric only is valid alphanumeric
}

run "mixed_case_suffix" {
  command = plan

  variables {
    sku           = "Standard_AzureFrontDoor"
    location      = "East US"
    tags = {
      Environment = "test"
    }
    custom_domain = "example.com"
    suffix        = "TeSt01"
  }

  # Should pass - mixed case alphanumeric is valid
}
