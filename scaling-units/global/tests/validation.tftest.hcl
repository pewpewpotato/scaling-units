# Test for variable validation logic without Azure authentication

provider "azurerm" {
  features {}
  skip_provider_registration = true
}

run "test_invalid_name_characters" {
  command = plan

  variables {
    location = "East US"
    tags     = {}
    suffix   = "001"
  }

  expect_failures = [
  ]
}

run "test_empty_name" {
  command = plan

  variables {
    location = "East US"
    tags     = {}
    suffix   = "001"
  }

  expect_failures = [
  ]
}

run "test_name_too_long" {
  command = plan

  variables {
    location = "East US"
    tags     = {}
    suffix   = "001"
  }

  expect_failures = [
  ]
}

run "test_empty_location" {
  command = plan

  variables {
    location = ""  # Empty location
    tags     = {}
    suffix   = "001"
  }

  expect_failures = [
    var.location,
  ]
}

run "test_invalid_suffix_characters" {
  command = plan

  variables {
    location = "East US"
    tags     = {}
    suffix   = "invalid-suffix!"  # Invalid characters
  }

  expect_failures = [
    var.suffix,
  ]
}

run "test_empty_suffix" {
  command = plan

  variables {
    location = "East US"
    tags     = {}
    suffix   = ""  # Empty suffix
  }

  expect_failures = [
    var.suffix,
  ]
}

run "test_suffix_too_long" {
  command = plan

  variables {
    location = "East US"
    tags     = {}
    suffix   = "12345678901"  # > 10 chars
  }

  expect_failures = [
    var.suffix,
  ]
}
