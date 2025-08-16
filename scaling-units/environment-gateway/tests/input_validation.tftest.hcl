provider "azurerm" {
  features {}
  skip_provider_registration = true
}

run "test_missing_vnet_name_input" {
  command = plan

  # Test with missing vnet_name input - should fail
  variables {
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

run "test_missing_vnet_resource_group_name_input" {
  command = plan

  # Test with missing vnet_resource_group_name input - should fail
  variables {
    vnet_name               = "test-vnet"
    nsg_name                = "test-nsg"
    nsg_resource_group_name = "test-nsg-rg"
    apim_subnet_prefix      = "10.0.1.0/24"
    location                = "eastus"
    tags = {
      environment = "test"
    }
    suffix = "test"
  }

  expect_failures = [
    var.vnet_resource_group_name,
  ]
}

run "test_missing_nsg_name_input" {
  command = plan

  # Test with missing nsg_name input - should fail
  variables {
    vnet_name                = "test-vnet"
    vnet_resource_group_name = "test-vnet-rg"
    nsg_resource_group_name  = "test-nsg-rg"
    apim_subnet_prefix       = "10.0.1.0/24"
    location                 = "eastus"
    tags = {
      environment = "test"
    }
    suffix = "test"
  }

  expect_failures = [
    var.nsg_name,
  ]
}

run "test_missing_nsg_resource_group_name_input" {
  command = plan

  # Test with missing nsg_resource_group_name input - should fail
  variables {
    vnet_name                = "test-vnet"
    vnet_resource_group_name = "test-vnet-rg"
    nsg_name                 = "test-nsg"
    apim_subnet_prefix       = "10.0.1.0/24"
    location                 = "eastus"
    tags = {
      environment = "test"
    }
    suffix = "test"
  }

  expect_failures = [
    var.nsg_resource_group_name,
  ]
}

run "test_missing_apim_subnet_prefix_input" {
  command = plan

  # Test with missing apim_subnet_prefix input - should fail
  variables {
    vnet_name                = "test-vnet"
    vnet_resource_group_name = "test-vnet-rg"
    nsg_name                 = "test-nsg"
    nsg_resource_group_name  = "test-nsg-rg"
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

run "test_missing_location_input" {
  command = plan

  # Test with missing location input - should fail
  variables {
    vnet_name                = "test-vnet"
    vnet_resource_group_name = "test-vnet-rg"
    nsg_name                 = "test-nsg"
    nsg_resource_group_name  = "test-nsg-rg"
    apim_subnet_prefix       = "10.0.1.0/24"
    tags = {
      environment = "test"
    }
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
    vnet_name                = "test-vnet"
    vnet_resource_group_name = "test-vnet-rg"
    nsg_name                 = "test-nsg"
    nsg_resource_group_name  = "test-nsg-rg"
    apim_subnet_prefix       = "10.0.1.0/24"
    location                 = "eastus"
    suffix                   = "test"
  }

  expect_failures = [
    var.tags,
  ]
}

run "test_missing_suffix_input" {
  command = plan

  # Test with missing suffix input - should fail
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
  }

  expect_failures = [
    var.suffix,
  ]
}

run "test_invalid_apim_subnet_prefix" {
  command = plan

  # Test with invalid CIDR - should fail
  variables {
    vnet_name                = "test-vnet"
    vnet_resource_group_name = "test-vnet-rg"
    nsg_name                 = "test-nsg"
    nsg_resource_group_name  = "test-nsg-rg"
    apim_subnet_prefix       = "invalid-cidr"
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
