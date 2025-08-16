provider "azurerm" {
  features {}
  skip_provider_registration = true
}

run "test_naming_conventions_applied" {
  command = plan

  variables {
    vnet_name                = "test-vnet"
    vnet_resource_group_name = "test-vnet-rg"
    nsg_name                 = "test-nsg"
    nsg_resource_group_name  = "test-nsg-rg"
    apim_subnet_prefix       = "10.0.1.0/24"
    location                 = "East US"
    tags = {
      environment = "test"
    }
    suffix = "prod001"
  }

  # Test that azure/naming module is used correctly
  assert {
    condition     = can(regex("^[a-zA-Z0-9-]+$", azurerm_resource_group.this.name))
    error_message = "Resource group name should follow Azure naming conventions"
  }

  assert {
    condition     = can(regex("^[a-zA-Z0-9-]+$", azurerm_api_management.this.name))
    error_message = "API Management name should follow Azure naming conventions"
  }

  assert {
    condition     = can(regex("^[a-zA-Z0-9-]+$", azurerm_subnet.apim.name))
    error_message = "Subnet name should follow Azure naming conventions"
  }

  # Test that suffix is properly incorporated
  assert {
    condition     = can(regex("prod001", azurerm_resource_group.this.name))
    error_message = "Resource group name should include the specified suffix"
  }

  assert {
    condition     = can(regex("prod001", azurerm_api_management.this.name))
    error_message = "API Management name should include the specified suffix"
  }
}

run "test_resource_name_uniqueness" {
  command = plan

  variables {
    vnet_name                = "test-vnet"
    vnet_resource_group_name = "test-vnet-rg"
    nsg_name                 = "test-nsg"
    nsg_resource_group_name  = "test-nsg-rg"
    apim_subnet_prefix       = "10.0.1.0/24"
    location                 = "East US"
    tags = {
      environment = "test"
    }
    suffix = "unique123"
  }

  # Test that different resource types have different names
  assert {
    condition     = azurerm_resource_group.this.name != azurerm_api_management.this.name
    error_message = "Resource group and API Management should have different names"
  }

  assert {
    condition     = azurerm_resource_group.this.name != azurerm_subnet.apim.name
    error_message = "Resource group and subnet should have different names"
  }

  assert {
    condition     = azurerm_api_management.this.name != azurerm_subnet.apim.name
    error_message = "API Management and subnet should have different names"
  }
}

run "test_naming_with_different_suffixes" {
  command = plan

  variables {
    vnet_name                = "test-vnet"
    vnet_resource_group_name = "test-vnet-rg"
    nsg_name                 = "test-nsg"
    nsg_resource_group_name  = "test-nsg-rg"
    apim_subnet_prefix       = "10.0.1.0/24"
    location                 = "East US"
    tags = {
      environment = "production"
      team        = "platform"
    }
    suffix = "abc123"
  }

  # Test that custom suffix is properly used
  assert {
    condition     = can(regex("abc123", azurerm_resource_group.this.name))
    error_message = "Custom suffix should be incorporated in resource names"
  }
}

run "test_naming_with_alphanumeric_suffix" {
  command = plan

  variables {
    vnet_name                = "test-vnet"
    vnet_resource_group_name = "test-vnet-rg"
    nsg_name                 = "test-nsg"
    nsg_resource_group_name  = "test-nsg-rg"
    apim_subnet_prefix       = "10.0.1.0/24"
    location                 = "East US"
    tags = {
      environment = "test"
    }
    suffix = "dev1"
  }

  # Test that mixed alphanumeric suffixes work
  assert {
    condition     = can(regex("dev1", azurerm_resource_group.this.name))
    error_message = "Alphanumeric suffix should be incorporated correctly"
  }

  assert {
    condition     = can(regex("dev1", azurerm_api_management.this.name))
    error_message = "Alphanumeric suffix should be in APIM name"
  }
}

run "test_nsg_rule_naming_consistency" {
  command = plan

  variables {
    vnet_name                = "test-vnet"
    vnet_resource_group_name = "test-vnet-rg"
    nsg_name                 = "test-nsg"
    nsg_resource_group_name  = "test-nsg-rg"
    apim_subnet_prefix       = "10.0.1.0/24"
    location                 = "East US"
    tags = {
      environment = "test"
    }
    suffix = "test"
  }

  # Test that NSG rules follow consistent naming
  assert {
    condition = alltrue([
      for rule_name, rule in azurerm_network_security_rule.apim_inbound :
      can(regex("^[A-Za-z][A-Za-z0-9]*$", rule_name))
    ])
    error_message = "Inbound NSG rule names should follow consistent naming pattern"
  }

  assert {
    condition = alltrue([
      for rule_name, rule in azurerm_network_security_rule.apim_outbound :
      can(regex("^[A-Za-z][A-Za-z0-9]*$", rule_name))
    ])
    error_message = "Outbound NSG rule names should follow consistent naming pattern"
  }
}

run "test_resource_tags_applied" {
  command = plan

  variables {
    vnet_name                = "test-vnet"
    vnet_resource_group_name = "test-vnet-rg"
    nsg_name                 = "test-nsg"
    nsg_resource_group_name  = "test-nsg-rg"
    apim_subnet_prefix       = "10.0.1.0/24"
    location                 = "East US"
    tags = {
      environment = "production"
      project     = "api-gateway"
      team        = "platform"
    }
    suffix = "prod"
  }

  # Test that tags are properly applied to resources
  assert {
    condition     = azurerm_resource_group.this.tags["environment"] == "production"
    error_message = "Resource group should have the specified tags"
  }

  assert {
    condition     = azurerm_api_management.this.tags["project"] == "api-gateway"
    error_message = "API Management should have the specified tags"
  }

  assert {
    condition     = azurerm_api_management.this.tags["team"] == "platform"
    error_message = "API Management should have all specified tags"
  }
}
