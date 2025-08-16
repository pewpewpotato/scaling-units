provider "azurerm" {
  features {}
  skip_provider_registration = true
}

run "test_invalid_subnet_cidr" {
  command = plan

  variables {
    vnet_name                = "test-vnet"
    vnet_resource_group_name = "test-vnet-rg"
    nsg_name                 = "test-nsg"
    nsg_resource_group_name  = "test-nsg-rg"
    apim_subnet_prefix       = "not-a-cidr"
    location                 = "eastus"
    tags = {
      environment = "test"
    }
    suffix = "test"
  }

  expect_failures = [
    var.apim_subnet_prefix,
  ]
}

run "test_subnet_cidr_too_large" {
  command = plan

  variables {
    vnet_name                = "test-vnet"
    vnet_resource_group_name = "test-vnet-rg"
    nsg_name                 = "test-nsg"
    nsg_resource_group_name  = "test-nsg-rg"
    apim_subnet_prefix       = "10.0.0.0/8"  # Too large for APIM subnet
    location                 = "eastus"
    tags = {
      environment = "test"
    }
    suffix = "test"
  }

  expect_failures = [
    var.apim_subnet_prefix,
  ]
}

run "test_subnet_cidr_too_small" {
  command = plan

  variables {
    vnet_name                = "test-vnet"
    vnet_resource_group_name = "test-vnet-rg"
    nsg_name                 = "test-nsg"
    nsg_resource_group_name  = "test-nsg-rg"
    apim_subnet_prefix       = "10.0.0.0/30"  # Too small for APIM
    location                 = "eastus"
    tags = {
      environment = "test"
    }
    suffix = "test"
  }

  expect_failures = [
    var.apim_subnet_prefix,
  ]
}

run "test_invalid_resource_names" {
  command = plan

  variables {
    vnet_name                = ""  # Empty name
    vnet_resource_group_name = "test-vnet-rg"
    nsg_name                 = "test-nsg"
    nsg_resource_group_name  = "test-nsg-rg"
    apim_subnet_prefix       = "10.0.1.0/24"
    location                 = "eastus"
    tags = {
      environment = "test"
    }
    suffix = "test"
  }

  expect_failures = [
    var.vnet_name,
  ]
}

run "test_suffix_with_special_characters" {
  command = plan

  variables {
    vnet_name                = "test-vnet"
    vnet_resource_group_name = "test-vnet-rg"
    nsg_name                 = "test-nsg"
    nsg_resource_group_name  = "test-nsg-rg"
    apim_subnet_prefix       = "10.0.1.0/24"
    location                 = "eastus"
    tags = {
      environment = "test"
    }
    suffix = "test-suffix!"  # Contains special character
  }

  expect_failures = [
    var.suffix,
  ]
}

run "test_suffix_too_long" {
  command = plan

  variables {
    vnet_name                = "test-vnet"
    vnet_resource_group_name = "test-vnet-rg"
    nsg_name                 = "test-nsg"
    nsg_resource_group_name  = "test-nsg-rg"
    apim_subnet_prefix       = "10.0.1.0/24"
    location                 = "eastus"
    tags = {
      environment = "test"
    }
    suffix = "verylongsuffix"  # More than 10 characters
  }

  expect_failures = [
    var.suffix,
  ]
}
