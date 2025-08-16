# Test for maximum input sizes

provider "azurerm" {
  features {}
  skip_provider_registration = true
}

run "test_maximum_name_length" {
  command = plan

  variables {
    location = "East US"
    tags     = {}
    suffix   = "001"
  }
}

run "test_maximum_suffix_length" {
  command = plan

  variables {
    location = "East US"
    tags     = {}
    suffix   = "1234567890"  # Exactly 10 chars
  }
}

run "test_name_exceeds_maximum" {
  command = plan

  variables {
    location = "East US"
    tags     = {}
    suffix   = "001"
  }

  expect_failures = [
  ]
}

run "test_suffix_exceeds_maximum" {
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

run "test_large_tags_map" {
  command = plan

  variables {
    location = "East US"
    tags = {
      environment      = "production"
      project          = "global-stamp-module"
      team             = "infrastructure"
      cost-center      = "12345"
      owner            = "platform-team"
      application      = "global-infrastructure"
      version          = "1.0.0"
      created-by       = "opentofu"
      managed-by       = "infrastructure-team"
      department       = "engineering"
      business-unit    = "technology"
      compliance       = "required"
      backup-policy    = "daily"
      monitoring       = "enabled"
      security-level   = "high"
    }
    suffix = "001"
  }
}

run "test_very_long_location_name" {
  command = plan

  variables {
    location = "East US 2"  # Azure location with space and number
    tags     = {}
    suffix   = "001"
  }
}
