# Test for Global Stamp Module Input Validation

provider "azurerm" {
  features {}
  skip_provider_registration = true
}

# Test that module requires all inputs
run "test_missing_required_inputs" {
  command = plan

  # Test with missing name input - should fail
  variables {
    location = "East US"
    tags     = {}
    suffix   = "test"
  }

  expect_failures = [
  ]
}

run "test_missing_location_input" {
  command = plan

  # Test with missing location input - should fail
  variables {
    tags   = {}
    suffix = "test"
  }

  expect_failures = [
    var.location,
  ]
}

run "test_missing_tags_input" {
  command = plan

  # Test with missing tags input - should fail
  variables {
    location = "East US"
    suffix   = "test"
  }

  expect_failures = [
    var.tags,
  ]
}

run "test_missing_suffix_input" {
  command = plan

  # Test with missing suffix input - should fail
  variables {
    location = "East US"
    tags     = {}
  }

  expect_failures = [
    var.suffix,
  ]
}

run "test_invalid_data_types" {
  command = plan

  # Test with invalid data types - should fail
  variables {
    location = "East US"
    tags     = "invalid"  # Should be map
    suffix   = ["array"]  # Should be string
  }

  expect_failures = [
    var.tags,
    var.suffix,
  ]
}
