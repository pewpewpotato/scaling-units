# Test: Output validation
# Tests to verify all module outputs are properly exposed and accessible

run "test_all_outputs_are_available" {
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

  # Verify all required outputs are available
  assert {
    condition     = output.resource_group_name != null
    error_message = "resource_group_name output should be available"
  }

  assert {
    condition     = output.cdn_profile_name != null
    error_message = "cdn_profile_name output should be available"
  }

  assert {
    condition     = output.resource_name != null
    error_message = "resource_name output should be available"
  }
}

run "test_resource_group_name_output_matches_resource" {
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

  # Verify resource_group_name output matches actual resource
  assert {
    condition     = output.resource_group_name == azurerm_resource_group.main.name
    error_message = "resource_group_name output should match the actual resource group name"
  }
}

run "test_cdn_profile_name_output_matches_resource" {
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

  # Verify cdn_profile_name output matches actual resource
  assert {
    condition     = output.cdn_profile_name == azurerm_cdn_frontdoor_profile.main.name
    error_message = "cdn_profile_name output should match the actual CDN profile name"
  }
}

run "test_resource_name_output_is_meaningful" {
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

  # Verify resource_name output provides meaningful information
  assert {
    condition     = length(output.resource_name) > 0
    error_message = "resource_name output should not be empty"
  }

  assert {
    condition     = can(regex("test01", output.resource_name))
    error_message = "resource_name output should include the suffix for identification"
  }
}

run "test_outputs_with_different_suffix" {
  command = plan

  variables {
    sku           = "Premium_AzureFrontDoor"
    location      = "West Europe"
    tags = {
      Environment = "production"
    }
    custom_domain = "prod.example.com"
    suffix        = "prod123"
  }

  # Verify outputs reflect different input values
  assert {
    condition     = can(regex("prod123", output.resource_group_name))
    error_message = "resource_group_name output should reflect different suffix values"
  }

  assert {
    condition     = can(regex("prod123", output.cdn_profile_name))
    error_message = "cdn_profile_name output should reflect different suffix values"
  }

  assert {
    condition     = can(regex("prod123", output.resource_name))
    error_message = "resource_name output should reflect different suffix values"
  }
}

run "test_outputs_for_downstream_consumption" {
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

  # Verify outputs are suitable for downstream module consumption
  assert {
    condition     = can(regex("^rg-.*", output.resource_group_name))
    error_message = "resource_group_name should follow Azure naming convention for downstream use"
  }

  assert {
    condition     = can(regex("^afd-.*", output.cdn_profile_name))
    error_message = "cdn_profile_name should follow Azure naming convention for downstream use"
  }
}

run "test_output_consistency_across_resources" {
  command = plan

  variables {
    sku           = "Standard_AzureFrontDoor"
    location      = "East US"
    tags = {
      Environment = "test"
    }
    custom_domain = "example.com"
    suffix        = "shared"
  }

  # Verify all outputs use consistent naming patterns
  assert {
    condition     = can(regex("shared$", output.resource_group_name)) && can(regex("shared$", output.cdn_profile_name))
    error_message = "All outputs should use consistent suffix for resource identification"
  }
}
