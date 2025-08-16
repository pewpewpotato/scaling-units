provider "azurerm" {
  features {}
  skip_provider_registration = true
}

# QA-023: Borderline valid/invalid values
run "test_whitespace_in_names" {
  command = plan

  variables {
    vnet_name                = "  "  # Only whitespace
    vnet_resource_group_name = "test-vnet-rg"
    nsg_name                 = "test-nsg"
    nsg_resource_group_name  = "test-nsg-rg"
    apim_subnet_prefix       = "10.0.1.0/24"
    location                 = "East US"
    tags                     = {}
    suffix                   = "test"
  }

  expect_failures = [
    var.vnet_name,
  ]
}

run "test_names_at_length_limits" {
  command = plan

  # Test names exactly at length limits
  variables {
    vnet_name                = "a234567890123456789012345678901234567890123456789012345678901234"  # 64 chars
    vnet_resource_group_name = "a23456789012345678901234567890123456789012345678901234567890123456789012345678901234567890"  # 90 chars
    nsg_name                 = "a2345678901234567890123456789012345678901234567890123456789012345678901234567890"  # 80 chars
    nsg_resource_group_name  = "a23456789012345678901234567890123456789012345678901234567890123456789012345678901234567890"  # 90 chars
    apim_subnet_prefix       = "10.0.1.0/29"  # Smallest valid subnet
    location                 = "East US"
    tags                     = {}
    suffix                   = "1234567890"  # 10 chars
  }

  assert {
    condition     = azurerm_api_management.this.name != null
    error_message = "Module should work with names at maximum length limits"
  }
}

run "test_names_exceeding_limits" {
  command = plan

  variables {
    vnet_name                = "a2345678901234567890123456789012345678901234567890123456789012345678901234567890"  # 65 chars (exceeds 64)
    vnet_resource_group_name = "test-vnet-rg"
    nsg_name                 = "test-nsg"
    nsg_resource_group_name  = "test-nsg-rg"
    apim_subnet_prefix       = "10.0.1.0/24"
    location                 = "East US"
    tags                     = {}
    suffix                   = "test"
  }

  expect_failures = [
    var.vnet_name,
  ]
}

# QA-025: Malicious input attempts
run "test_script_injection_in_names" {
  command = plan

  variables {
    vnet_name                = "<script>alert('xss')</script>"
    vnet_resource_group_name = "test-vnet-rg"
    nsg_name                 = "test-nsg"
    nsg_resource_group_name  = "test-nsg-rg"
    apim_subnet_prefix       = "10.0.1.0/24"
    location                 = "East US"
    tags                     = {}
    suffix                   = "test"
  }

  expect_failures = [
    var.vnet_name,
  ]
}

run "test_sql_injection_in_suffix" {
  command = plan

  variables {
    vnet_name                = "test-vnet"
    vnet_resource_group_name = "test-vnet-rg"
    nsg_name                 = "test-nsg"
    nsg_resource_group_name  = "test-nsg-rg"
    apim_subnet_prefix       = "10.0.1.0/24"
    location                 = "East US"
    tags                     = {}
    suffix                   = "'; DROP TABLE"
  }

  expect_failures = [
    var.suffix,
  ]
}

run "test_path_traversal_in_names" {
  command = plan

  variables {
    vnet_name                = "../../../etc/passwd"
    vnet_resource_group_name = "test-vnet-rg"
    nsg_name                 = "test-nsg"
    nsg_resource_group_name  = "test-nsg-rg"
    apim_subnet_prefix       = "10.0.1.0/24"
    location                 = "East US"
    tags                     = {}
    suffix                   = "test"
  }

  expect_failures = [
    var.vnet_name,
  ]
}

run "test_reserved_azure_keywords_in_tags" {
  command = plan

  variables {
    vnet_name                = "test-vnet"
    vnet_resource_group_name = "test-vnet-rg"
    nsg_name                 = "test-nsg"
    nsg_resource_group_name  = "test-nsg-rg"
    apim_subnet_prefix       = "10.0.1.0/24"
    location                 = "East US"
    tags = {
      "microsoft.restricted" = "value"  # Should fail
    }
    suffix = "test"
  }

  expect_failures = [
    var.tags,
  ]
}

run "test_unicode_attacks_in_names" {
  command = plan

  variables {
    vnet_name                = "test\u0000vnet"  # Null byte
    vnet_resource_group_name = "test-vnet-rg"
    nsg_name                 = "test-nsg"
    nsg_resource_group_name  = "test-nsg-rg"
    apim_subnet_prefix       = "10.0.1.0/24"
    location                 = "East US"
    tags                     = {}
    suffix                   = "test"
  }

  expect_failures = [
    var.vnet_name,
  ]
}

# QA-004: Edge case subnet configurations
run "test_boundary_subnet_sizes" {
  command = plan

  # Test exactly at the boundaries
  variables {
    vnet_name                = "test-vnet"
    vnet_resource_group_name = "test-vnet-rg"
    nsg_name                 = "test-nsg"
    nsg_resource_group_name  = "test-nsg-rg"
    apim_subnet_prefix       = "10.0.1.0/16"  # Largest valid
    location                 = "East US"
    tags                     = {}
    suffix                   = "test"
  }

  assert {
    condition     = azurerm_subnet.apim.name != null
    error_message = "Module should work with largest valid subnet size"
  }
}

run "test_special_characters_in_valid_names" {
  command = plan

  variables {
    vnet_name                = "test-vnet_with.periods-and_underscores"
    vnet_resource_group_name = "test-rg_with.periods-and_underscores"
    nsg_name                 = "test-nsg_with.periods-and_underscores"
    nsg_resource_group_name  = "test-nsg-rg_with.periods-and_underscores"
    apim_subnet_prefix       = "10.0.1.0/24"
    location                 = "East US"
    tags                     = {}
    suffix                   = "test123"
  }

  assert {
    condition     = azurerm_api_management.this.name != null
    error_message = "Module should work with valid special characters in names"
  }
}
