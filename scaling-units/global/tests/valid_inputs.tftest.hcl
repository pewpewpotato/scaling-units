# Test for Global Stamp Module with Valid Inputs

provider "azurerm" {
  features {}
  skip_provider_registration = true
}

run "test_valid_inputs" {
  command = plan

  variables {
    location = "East US"
    tags = {
      environment = "test"
      project     = "global-stamp"
    }
    suffix = "001"
  }
}

run "test_minimal_valid_inputs" {
  command = plan

  variables {
    location = "West US"
    tags     = {}
    suffix   = "1"
  }
}

run "test_maximum_length_inputs" {
  command = plan

  variables {
    location = "East US"
    tags = {
      environment = "production"
      project     = "global-stamp-module"
      team        = "infrastructure"
      cost-center = "12345"
      owner       = "platform-team"
    }
    suffix = "1234567890"  # 10 chars
  }
}
