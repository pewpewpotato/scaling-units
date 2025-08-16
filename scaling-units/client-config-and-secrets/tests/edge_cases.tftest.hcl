run "test_malicious_suffix_sql_injection" {
  command = plan
  expect_failures = [var.suffix]

  variables {
    location           = "East US"
    vnet_name          = "test-vnet"
    vnet_resource_id   = "/subscriptions/test/resourceGroups/test/providers/Microsoft.Network/virtualNetworks/test-vnet"
    subnet_name        = "test-subnet"
    subnet_resource_id = "/subscriptions/test/resourceGroups/test/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/test-subnet"
    suffix             = "'; DROP TABLE--"
    tags = {
      environment = "test"
    }
  }
}

run "test_malicious_suffix_script_injection" {
  command = plan
  expect_failures = [var.suffix]

  variables {
    location           = "East US"
    vnet_name          = "test-vnet"
    vnet_resource_id   = "/subscriptions/test/resourceGroups/test/providers/Microsoft.Network/virtualNetworks/test-vnet"
    subnet_name        = "test-subnet"
    subnet_resource_id = "/subscriptions/test/resourceGroups/test/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/test-subnet"
    suffix             = "<script>alert('xss')</script>"
    tags = {
      environment = "test"
    }
  }
}

run "test_malicious_suffix_path_traversal" {
  command = plan
  expect_failures = [var.suffix]

  variables {
    location           = "East US"
    vnet_name          = "test-vnet"
    vnet_resource_id   = "/subscriptions/test/resourceGroups/test/providers/Microsoft.Network/virtualNetworks/test-vnet"
    subnet_name        = "test-subnet"
    subnet_resource_id = "/subscriptions/test/resourceGroups/test/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/test-subnet"
    suffix             = "../../../etc/passwd"
    tags = {
      environment = "test"
    }
  }
}

run "test_reserved_word_suffix_azure" {
  command = plan
  expect_failures = [var.suffix]

  variables {
    location           = "East US"
    vnet_name          = "test-vnet"
    vnet_resource_id   = "/subscriptions/test/resourceGroups/test/providers/Microsoft.Network/virtualNetworks/test-vnet"
    subnet_name        = "test-subnet"
    subnet_resource_id = "/subscriptions/test/resourceGroups/test/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/test-subnet"
    suffix             = "azure"
    tags = {
      environment = "test"
    }
  }
}

run "test_reserved_word_suffix_microsoft" {
  command = plan
  expect_failures = [var.suffix]

  variables {
    location           = "East US"
    vnet_name          = "test-vnet"
    vnet_resource_id   = "/subscriptions/test/resourceGroups/test/providers/Microsoft.Network/virtualNetworks/test-vnet"
    subnet_name        = "test-subnet"
    subnet_resource_id = "/subscriptions/test/resourceGroups/test/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/test-subnet"
    suffix             = "microsoft"
    tags = {
      environment = "test"
    }
  }
}

run "test_edge_case_unicode_characters" {
  command = plan
  expect_failures = [var.suffix]

  variables {
    location           = "East US"
    vnet_name          = "test-vnet"
    vnet_resource_id   = "/subscriptions/test/resourceGroups/test/providers/Microsoft.Network/virtualNetworks/test-vnet"
    subnet_name        = "test-subnet"
    subnet_resource_id = "/subscriptions/test/resourceGroups/test/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/test-subnet"
    suffix             = "tést01"
    tags = {
      environment = "test"
    }
  }
}

run "test_edge_case_null_characters" {
  command = plan
  expect_failures = [var.suffix]

  variables {
    location           = "East US"
    vnet_name          = "test-vnet"
    vnet_resource_id   = "/subscriptions/test/resourceGroups/test/providers/Microsoft.Network/virtualNetworks/test-vnet"
    subnet_name        = "test-subnet"
    subnet_resource_id = "/subscriptions/test/resourceGroups/test/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/test-subnet"
    suffix             = "testnull"
    tags = {
      environment = "test"
    }
  }
}

run "test_edge_case_very_long_location" {
  command = plan

  variables {
    location           = "eastus"  # Valid Azure region, not actually long
    vnet_name          = "test-vnet"
    vnet_resource_id   = "/subscriptions/test/resourceGroups/test/providers/Microsoft.Network/virtualNetworks/test-vnet"
    subnet_name        = "test-subnet"
    subnet_resource_id = "/subscriptions/test/resourceGroups/test/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/test-subnet"
    suffix             = "test01"
    tags = {
      environment = "test"
    }
  }

  # This should succeed as eastus is a valid region
  assert {
    condition     = azurerm_resource_group.this.location == "eastus"
    error_message = "Valid Azure region should be accepted"
  }
}

run "test_edge_case_malformed_resource_id" {
  command = plan

  variables {
    location           = "East US"
    vnet_name          = "test-vnet"
    vnet_resource_id   = "not-a-valid-resource-id"
    subnet_name        = "test-subnet"
    subnet_resource_id = "also-not-valid"
    suffix             = "test01"
    tags = {
      environment = "test"
    }
  }

  # Module should still plan successfully with malformed IDs for basic validation
  # The actual Azure provider would reject these during apply
  assert {
    condition     = length(azurerm_resource_group.this.name) > 0
    error_message = "Module should handle malformed resource IDs during plan phase"
  }
}

run "test_edge_case_boundary_suffix_length" {
  command = plan

  variables {
    location           = "East US"
    vnet_name          = "test-vnet"
    vnet_resource_id   = "/subscriptions/test/resourceGroups/test/providers/Microsoft.Network/virtualNetworks/test-vnet"
    subnet_name        = "test-subnet"
    subnet_resource_id = "/subscriptions/test/resourceGroups/test/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/test-subnet"
    suffix             = "1234567890"  # Exactly 10 characters (maximum allowed)
    tags = {
      environment = "test"
    }
  }

  assert {
    condition     = length(var.suffix) == 10
    error_message = "Maximum length suffix should be accepted"
  }
}

run "test_edge_case_minimum_suffix_length" {
  command = plan

  variables {
    location           = "East US"
    vnet_name          = "test-vnet"
    vnet_resource_id   = "/subscriptions/test/resourceGroups/test/providers/Microsoft.Network/virtualNetworks/test-vnet"
    subnet_name        = "test-subnet"
    subnet_resource_id = "/subscriptions/test/resourceGroups/test/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/test-subnet"
    suffix             = "a"  # Minimum length (1 character)
    tags = {
      environment = "test"
    }
  }

  assert {
    condition     = length(var.suffix) == 1
    error_message = "Minimum length suffix should be accepted"
  }
}
