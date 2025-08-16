# Test: Custom domain validation
# Tests for valid and invalid custom domain formats

run "valid_simple_domain" {
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

  # Should pass - simple valid domain
}

run "valid_subdomain" {
  command = plan

  variables {
    sku           = "Standard_AzureFrontDoor"
    location      = "East US"
    tags = {
      Environment = "test"
    }
    custom_domain = "api.example.com"
    suffix        = "test01"
  }

  # Should pass - valid subdomain
}

run "valid_deep_subdomain" {
  command = plan

  variables {
    sku           = "Standard_AzureFrontDoor"
    location      = "East US"
    tags = {
      Environment = "test"
    }
    custom_domain = "api.v1.example.com"
    suffix        = "test01"
  }

  # Should pass - valid deep subdomain
}

run "valid_domain_with_hyphens" {
  command = plan

  variables {
    sku           = "Standard_AzureFrontDoor"
    location      = "East US"
    tags = {
      Environment = "test"
    }
    custom_domain = "my-api.example-site.com"
    suffix        = "test01"
  }

  # Should pass - valid domain with hyphens
}

run "valid_numeric_subdomain" {
  command = plan

  variables {
    sku           = "Standard_AzureFrontDoor"
    location      = "East US"
    tags = {
      Environment = "test"
    }
    custom_domain = "api1.example.com"
    suffix        = "test01"
  }

  # Should pass - valid numeric in subdomain
}

run "invalid_domain_no_tld" {
  command = plan

  variables {
    sku           = "Standard_AzureFrontDoor"
    location      = "East US"
    tags = {
      Environment = "test"
    }
    custom_domain = "localhost"
    suffix        = "test01"
  }

  expect_failures = [
    var.custom_domain,
  ]
}

run "invalid_domain_starts_with_hyphen" {
  command = plan

  variables {
    sku           = "Standard_AzureFrontDoor"
    location      = "East US"
    tags = {
      Environment = "test"
    }
    custom_domain = "-invalid.example.com"
    suffix        = "test01"
  }

  expect_failures = [
    var.custom_domain,
  ]
}

run "invalid_domain_ends_with_hyphen" {
  command = plan

  variables {
    sku           = "Standard_AzureFrontDoor"
    location      = "East US"
    tags = {
      Environment = "test"
    }
    custom_domain = "invalid-.example.com"
    suffix        = "test01"
  }

  expect_failures = [
    var.custom_domain,
  ]
}

run "invalid_domain_double_hyphen" {
  command = plan

  variables {
    sku           = "Standard_AzureFrontDoor"
    location      = "East US"
    tags = {
      Environment = "test"
    }
    custom_domain = "invalid--.example.com"
    suffix        = "test01"
  }

  expect_failures = [
    var.custom_domain,
  ]
}

run "invalid_domain_special_characters" {
  command = plan

  variables {
    sku           = "Standard_AzureFrontDoor"
    location      = "East US"
    tags = {
      Environment = "test"
    }
    custom_domain = "invalid@domain.com"
    suffix        = "test01"
  }

  expect_failures = [
    var.custom_domain,
  ]
}

run "invalid_domain_underscore" {
  command = plan

  variables {
    sku           = "Standard_AzureFrontDoor"
    location      = "East US"
    tags = {
      Environment = "test"
    }
    custom_domain = "invalid_domain.com"
    suffix        = "test01"
  }

  expect_failures = [
    var.custom_domain,
  ]
}

run "invalid_domain_spaces" {
  command = plan

  variables {
    sku           = "Standard_AzureFrontDoor"
    location      = "East US"
    tags = {
      Environment = "test"
    }
    custom_domain = "invalid domain.com"
    suffix        = "test01"
  }

  expect_failures = [
    var.custom_domain,
  ]
}

run "invalid_domain_too_long_label" {
  command = plan

  variables {
    sku           = "Standard_AzureFrontDoor"
    location      = "East US"
    tags = {
      Environment = "test"
    }
    custom_domain = "this-is-a-very-long-subdomain-name-that-exceeds-the-maximum-length-allowed-for-dns-labels-which-is-sixty-three-characters.example.com"
    suffix        = "test01"
  }

  expect_failures = [
    var.custom_domain,
  ]
}

run "invalid_domain_single_character_tld" {
  command = plan

  variables {
    sku           = "Standard_AzureFrontDoor"
    location      = "East US"
    tags = {
      Environment = "test"
    }
    custom_domain = "example.c"
    suffix        = "test01"
  }

  expect_failures = [
    var.custom_domain,
  ]
}

run "invalid_empty_domain" {
  command = plan

  variables {
    sku           = "Standard_AzureFrontDoor"
    location      = "East US"
    tags = {
      Environment = "test"
    }
    custom_domain = ""
    suffix        = "test01"
  }

  expect_failures = [
    var.custom_domain,
  ]
}
