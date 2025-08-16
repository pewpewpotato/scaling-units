provider "azurerm" {
  features {}
  skip_provider_registration = true
}

# QA-003: Missing or invalid vnet/NSG/location
run "test_missing_vnet_name" {
  command = plan

  variables {
    vnet_resource_group_name = "test-vnet-rg"
    nsg_name                 = "test-nsg"
    nsg_resource_group_name  = "test-nsg-rg"
    apim_subnet_prefix       = "10.0.1.0/24"
    location                 = "East US"
    tags                     = {}
    suffix                   = "test"
  }

  expect_failures = [
    var.vnet_name,
  ]
}

run "test_missing_location" {
  command = plan

  variables {
    vnet_name                = "test-vnet"
    vnet_resource_group_name = "test-vnet-rg"
    nsg_name                 = "test-nsg"
    nsg_resource_group_name  = "test-nsg-rg"
    apim_subnet_prefix       = "10.0.1.0/24"
    tags                     = {}
    suffix                   = "test"
  }

  expect_failures = [
    var.location,
  ]
}

# QA-012: Invalid subnet configuration
run "test_invalid_subnet_cidr" {
  command = plan

  variables {
    vnet_name                = "test-vnet"
    vnet_resource_group_name = "test-vnet-rg"
    nsg_name                 = "test-nsg"
    nsg_resource_group_name  = "test-nsg-rg"
    apim_subnet_prefix       = "invalid-cidr-format"
    location                 = "East US"
    tags                     = {}
    suffix                   = "test"
  }

  expect_failures = [
    var.apim_subnet_prefix,
  ]
}

run "test_subnet_too_small" {
  command = plan

  variables {
    vnet_name                = "test-vnet"
    vnet_resource_group_name = "test-vnet-rg"
    nsg_name                 = "test-nsg"
    nsg_resource_group_name  = "test-nsg-rg"
    apim_subnet_prefix       = "10.0.1.0/30"  # Too small for APIM
    location                 = "East US"
    tags                     = {}
    suffix                   = "test"
  }

  expect_failures = [
    var.apim_subnet_prefix,
  ]
}

run "test_subnet_too_large" {
  command = plan

  variables {
    vnet_name                = "test-vnet"
    vnet_resource_group_name = "test-vnet-rg"
    nsg_name                 = "test-nsg"
    nsg_resource_group_name  = "test-nsg-rg"
    apim_subnet_prefix       = "10.0.0.0/8"   # Too large for practical APIM subnet
    location                 = "East US"
    tags                     = {}
    suffix                   = "test"
  }

  expect_failures = [
    var.apim_subnet_prefix,
  ]
}

# QA-022: Omit required inputs
run "test_missing_tags" {
  command = plan

  variables {
    vnet_name                = "test-vnet"
    vnet_resource_group_name = "test-vnet-rg"
    nsg_name                 = "test-nsg"
    nsg_resource_group_name  = "test-nsg-rg"
    apim_subnet_prefix       = "10.0.1.0/24"
    location                 = "East US"
    suffix                   = "test"
  }

  expect_failures = [
    var.tags,
  ]
}

run "test_missing_suffix" {
  command = plan

  variables {
    vnet_name                = "test-vnet"
    vnet_resource_group_name = "test-vnet-rg"
    nsg_name                 = "test-nsg"
    nsg_resource_group_name  = "test-nsg-rg"
    apim_subnet_prefix       = "10.0.1.0/24"
    location                 = "East US"
    tags                     = {}
  }

  expect_failures = [
    var.suffix,
  ]
}

# QA-024: Wrong data types
run "test_invalid_tags_type" {
  command = plan

  variables {
    vnet_name                = "test-vnet"
    vnet_resource_group_name = "test-vnet-rg"
    nsg_name                 = "test-nsg"
    nsg_resource_group_name  = "test-nsg-rg"
    apim_subnet_prefix       = "10.0.1.0/24"
    location                 = "East US"
    tags                     = "invalid-type"  # Should be map
    suffix                   = "test"
  }

  expect_failures = [
    var.tags,
  ]
}

run "test_invalid_suffix_type" {
  command = plan

  variables {
    vnet_name                = "test-vnet"
    vnet_resource_group_name = "test-vnet-rg"
    nsg_name                 = "test-nsg"
    nsg_resource_group_name  = "test-nsg-rg"
    apim_subnet_prefix       = "10.0.1.0/24"
    location                 = "East US"
    tags                     = {}
    suffix                   = 123  # Should be string
  }

  expect_failures = [
    var.suffix,
  ]
}

# QA-032: Test documentation consistency
run "test_empty_resource_names" {
  command = plan

  variables {
    vnet_name                = ""  # Empty string
    vnet_resource_group_name = "test-vnet-rg"
    nsg_name                 = "test-nsg"
    nsg_resource_group_name  = "test-nsg-rg"
    apim_subnet_prefix       = "10.0.1.0/24"
    location                 = "East US"
    tags                     = {}
    suffix                   = "test"
  }

  expect_failures = [
    var.vnet_name,
  ]
}
