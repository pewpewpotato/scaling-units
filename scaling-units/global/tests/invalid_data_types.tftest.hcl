# Test for invalid data types

provider "azurerm" {
  features {}
  skip_provider_registration = true
}

run "test_integer_name_should_fail" {
  command = plan

  variables {
    location = "East US"
    tags     = {}
    suffix   = "001"
  }

  expect_failures = [
  ]
}

run "test_list_name_should_fail" {
  command = plan

  variables {
    location = "East US"
    tags     = {}
    suffix   = "001"
  }

  expect_failures = [
  ]
}

run "test_integer_location_should_fail" {
  command = plan

  variables {
    location = 123  # Should be string
    tags     = {}
    suffix   = "001"
  }

  expect_failures = [
    var.location,
  ]
}

run "test_string_tags_should_fail" {
  command = plan

  variables {
    location = "East US"
    tags     = "invalid string"  # Should be map(string)
    suffix   = "001"
  }

  expect_failures = [
    var.tags,
  ]
}

run "test_list_tags_should_fail" {
  command = plan

  variables {
    location = "East US"
    tags     = ["invalid", "list"]  # Should be map(string)
    suffix   = "001"
  }

  expect_failures = [
    var.tags,
  ]
}

run "test_integer_suffix_should_fail" {
  command = plan

  variables {
    location = "East US"
    tags     = {}
    suffix   = 123  # Should be string
  }

  expect_failures = [
    var.suffix,
  ]
}

run "test_list_suffix_should_fail" {
  command = plan

  variables {
    location = "East US"
    tags     = {}
    suffix   = ["invalid", "list"]  # Should be string
  }

  expect_failures = [
    var.suffix,
  ]
}
