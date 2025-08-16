# Test for minimal valid inputs

provider "azurerm" {
  features {}
  skip_provider_registration = true
}

run "test_minimal_inputs_single_char_values" {
  command = plan

  variables {
    location = "West US"  # Standard location
    tags     = {}         # Empty tags map (key minimal input test)
    suffix   = "1"        # Minimal single character suffix
  }
}

run "test_minimal_inputs_short_values" {
  command = plan

  variables {
    location = "East US"  # Standard location
    tags     = {}         # Empty tags map
    suffix   = "01"       # Short suffix
  }
}

run "test_minimal_inputs_with_space_in_location" {
  command = plan

  variables {
    location = "West US 2"  # Location with space and number
    tags     = {}           # Empty tags map
    suffix   = "99"
  }
}
