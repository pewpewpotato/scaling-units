# Test for edge-case suffixes per azure/naming conventions

provider "azurerm" {
  features {}
  skip_provider_registration = true
}

run "test_single_digit_suffix" {
  command = plan

  variables {
    location = "East US"
    tags     = {}
    suffix   = "0"  # Single digit - should be valid
  }
}

run "test_single_letter_suffix" {
  command = plan

  variables {
    location = "East US"
    tags     = {}
    suffix   = "a"  # Single letter - should be valid
  }
}

run "test_uppercase_suffix" {
  command = plan

  variables {
    location = "East US"
    tags     = {}
    suffix   = "ABC"  # Uppercase letters - should be valid
  }
}

run "test_mixed_case_suffix" {
  command = plan

  variables {
    location = "East US"
    tags     = {}
    suffix   = "Aa1Bb2"  # Mixed case and numbers - should be valid
  }
}

run "test_empty_suffix_should_fail" {
  command = plan

  variables {
    location = "East US"
    tags     = {}
    suffix   = ""  # Empty suffix - should fail
  }

  expect_failures = [
    var.suffix,
  ]
}

run "test_exactly_10_char_suffix" {
  command = plan

  variables {
    location = "East US"
    tags     = {}
    suffix   = "1234567890"  # Exactly 10 chars - should be valid
  }
}

run "test_11_char_suffix_should_fail" {
  command = plan

  variables {
    location = "East US"
    tags     = {}
    suffix   = "12345678901"  # 11 chars - should fail
  }

  expect_failures = [
    var.suffix,
  ]
}

run "test_suffix_with_leading_zero" {
  command = plan

  variables {
    location = "East US"
    tags     = {}
    suffix   = "001"  # Leading zeros - should be valid
  }
}

run "test_suffix_all_zeros" {
  command = plan

  variables {
    location = "East US"
    tags     = {}
    suffix   = "000"  # All zeros - should be valid
  }
}

run "test_suffix_all_letters" {
  command = plan

  variables {
    location = "East US"
    tags     = {}
    suffix   = "abcXYZ"  # All letters mixed case - should be valid
  }
}
