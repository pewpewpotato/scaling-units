# Test for azure/naming suffix validation rules

provider "azurerm" {
  features {}
  skip_provider_registration = true
}

run "test_suffix_with_azure_naming_validation" {
  command = plan

  variables {
    location = "East US"
    tags     = {}
    suffix   = "valid123"  # Valid alphanumeric suffix
  }
}

run "test_suffix_with_hyphens_should_fail" {
  command = plan

  variables {
    location = "East US"
    tags     = {}
    suffix   = "invalid-suffix"  # Contains hyphen - should be rejected
  }

  expect_failures = [
    var.suffix,
  ]
}

run "test_suffix_with_special_chars_should_fail" {
  command = plan

  variables {
    location = "East US"
    tags     = {}
    suffix   = "invalid@suffix!"  # Contains special characters - should be rejected
  }

  expect_failures = [
    var.suffix,
  ]
}

run "test_suffix_starting_with_number" {
  command = plan

  variables {
    location = "East US"
    tags     = {}
    suffix   = "123valid"  # Starts with number - should be valid for most Azure resources
  }
}

run "test_suffix_only_numbers" {
  command = plan

  variables {
    location = "East US"
    tags     = {}
    suffix   = "12345"  # Only numbers - should be valid
  }
}

run "test_suffix_only_letters" {
  command = plan

  variables {
    location = "East US"
    tags     = {}
    suffix   = "abcde"  # Only letters - should be valid
  }
}
