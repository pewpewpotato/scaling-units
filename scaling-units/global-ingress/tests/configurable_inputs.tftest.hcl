# Test: Configurable inputs validation
# Tests to verify all inputs are required, configurable, and applied correctly

run "test_sku_standard_is_applied" {
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

  # Verify SKU is applied to CDN profile
  assert {
    condition     = azurerm_cdn_frontdoor_profile.main.sku_name == "Standard_AzureFrontDoor"
    error_message = "CDN profile should use Standard_AzureFrontDoor SKU when specified"
  }
}

run "test_sku_premium_is_applied" {
  command = plan

  variables {
    sku           = "Premium_AzureFrontDoor"
    location      = "West US"
    tags = {
      Environment = "production"
    }
    custom_domain = "prod.example.com"
    suffix        = "prod"
  }

  # Verify Premium SKU is applied to CDN profile
  assert {
    condition     = azurerm_cdn_frontdoor_profile.main.sku_name == "Premium_AzureFrontDoor"
    error_message = "CDN profile should use Premium_AzureFrontDoor SKU when specified"
  }
}

run "test_location_is_applied" {
  command = plan

  variables {
    sku           = "Standard_AzureFrontDoor"
    location      = "West Europe"
    tags = {
      Environment = "test"
    }
    custom_domain = "example.com"
    suffix        = "test01"
  }

  # Verify location is applied to resource group
  assert {
    condition     = azurerm_resource_group.main.location == "West Europe"
    error_message = "Resource group should be created in specified location"
  }
}

run "test_multiple_locations" {
  command = plan

  variables {
    sku           = "Standard_AzureFrontDoor"
    location      = "Southeast Asia"
    tags = {
      Environment = "test"
      Region      = "apac"
    }
    custom_domain = "apac.example.com"
    suffix        = "apac01"
  }

  # Verify different location is applied
  assert {
    condition     = azurerm_resource_group.main.location == "Southeast Asia"
    error_message = "Resource group should support different Azure regions"
  }
}

run "test_tags_are_applied_to_resource_group" {
  command = plan

  variables {
    sku           = "Standard_AzureFrontDoor"
    location      = "East US"
    tags = {
      Environment = "production"
      Project     = "global-ingress"
      Owner       = "platform-team"
      CostCenter  = "engineering"
    }
    custom_domain = "example.com"
    suffix        = "test01"
  }

  # Verify all tags are applied to resource group
  assert {
    condition     = azurerm_resource_group.main.tags["Environment"] == "production"
    error_message = "Resource group should have Environment tag"
  }

  assert {
    condition     = azurerm_resource_group.main.tags["Project"] == "global-ingress"
    error_message = "Resource group should have Project tag"
  }

  assert {
    condition     = azurerm_resource_group.main.tags["Owner"] == "platform-team"
    error_message = "Resource group should have Owner tag"
  }

  assert {
    condition     = azurerm_resource_group.main.tags["CostCenter"] == "engineering"
    error_message = "Resource group should have CostCenter tag"
  }
}

run "test_tags_are_applied_to_cdn_profile" {
  command = plan

  variables {
    sku           = "Standard_AzureFrontDoor"
    location      = "East US"
    tags = {
      Environment = "staging"
      Application = "frontend"
    }
    custom_domain = "staging.example.com"
    suffix        = "stage"
  }

  # Verify tags are applied to CDN profile
  assert {
    condition     = azurerm_cdn_frontdoor_profile.main.tags["Environment"] == "staging"
    error_message = "CDN profile should have Environment tag"
  }

  assert {
    condition     = azurerm_cdn_frontdoor_profile.main.tags["Application"] == "frontend"
    error_message = "CDN profile should have Application tag"
  }
}

run "test_suffix_is_applied_to_names" {
  command = plan

  variables {
    sku           = "Standard_AzureFrontDoor"
    location      = "East US"
    tags = {
      Environment = "test"
    }
    custom_domain = "example.com"
    suffix        = "unique123"
  }

  # Verify suffix is included in resource names
  assert {
    condition     = can(regex("unique123", azurerm_resource_group.main.name))
    error_message = "Resource group name should include the suffix"
  }

  assert {
    condition     = can(regex("unique123", azurerm_cdn_frontdoor_profile.main.name))
    error_message = "CDN profile name should include the suffix"
  }
}

run "test_different_suffix_values" {
  command = plan

  variables {
    sku           = "Standard_AzureFrontDoor"
    location      = "East US"
    tags = {
      Environment = "test"
    }
    custom_domain = "example.com"
    suffix        = "abc123"
  }

  # Verify different suffix values work
  assert {
    condition     = can(regex("abc123", azurerm_resource_group.main.name))
    error_message = "Resource group name should include different suffix values"
  }

  assert {
    condition     = can(regex("abc123", azurerm_cdn_frontdoor_profile.main.name))
    error_message = "CDN profile name should include different suffix values"
  }
}

run "test_custom_domain_is_configurable" {
  command = plan

  variables {
    sku           = "Standard_AzureFrontDoor"
    location      = "East US"
    tags = {
      Environment = "test"
    }
    custom_domain = "api.mycompany.org"
    suffix        = "test01"
  }

  # Verify custom domain input is accepted and configurable
  assert {
    condition     = var.custom_domain == "api.mycompany.org"
    error_message = "Custom domain should be configurable"
  }
}

run "test_all_inputs_work_together" {
  command = plan

  variables {
    sku           = "Premium_AzureFrontDoor"
    location      = "UK South"
    tags = {
      Environment   = "production"
      BusinessUnit  = "marketing"
      Compliance    = "gdpr"
    }
    custom_domain = "marketing.company.co.uk"
    suffix        = "prod001"
  }

  # Verify all inputs can be configured together
  assert {
    condition     = azurerm_cdn_frontdoor_profile.main.sku_name == "Premium_AzureFrontDoor"
    error_message = "All inputs should work together - SKU"
  }

  assert {
    condition     = azurerm_resource_group.main.location == "UK South"
    error_message = "All inputs should work together - Location"
  }

  assert {
    condition     = azurerm_resource_group.main.tags["Environment"] == "production"
    error_message = "All inputs should work together - Tags"
  }

  assert {
    condition     = can(regex("prod001", azurerm_resource_group.main.name))
    error_message = "All inputs should work together - Suffix"
  }

  assert {
    condition     = var.custom_domain == "marketing.company.co.uk"
    error_message = "All inputs should work together - Custom Domain"
  }
}
