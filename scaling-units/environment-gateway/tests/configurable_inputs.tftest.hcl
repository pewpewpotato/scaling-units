provider "azurerm" {
  features {}
  skip_provider_registration = true
}

run "test_different_azure_regions" {
  command = plan

  variables {
    vnet_name                = "test-vnet"
    vnet_resource_group_name = "test-vnet-rg"
    nsg_name                 = "test-nsg"
    nsg_resource_group_name  = "test-nsg-rg"
    apim_subnet_prefix       = "10.0.1.0/24"
    location                 = "West Europe"
    tags = {
      environment = "test"
    }
    suffix = "eu001"
  }

  assert {
    condition     = azurerm_resource_group.this.location == "West Europe"
    error_message = "Resource group should be created in the specified location"
  }

  assert {
    condition     = azurerm_api_management.this.location == "West Europe"
    error_message = "API Management should be created in the specified location"
  }
}

run "test_different_subnet_configurations" {
  command = plan

  variables {
    vnet_name                = "production-vnet"
    vnet_resource_group_name = "network-rg"
    nsg_name                 = "apim-nsg"
    nsg_resource_group_name  = "security-rg"
    apim_subnet_prefix       = "172.16.10.0/26"  # Different network range and size
    location                 = "East US"
    tags = {
      environment = "production"
    }
    suffix = "prod"
  }

  assert {
    condition     = contains(azurerm_subnet.apim.address_prefixes, "172.16.10.0/26")
    error_message = "Subnet should use the specified CIDR block"
  }

  assert {
    condition     = azurerm_subnet.apim.virtual_network_name == "production-vnet"
    error_message = "Subnet should be created in the specified virtual network"
  }
}

run "test_different_resource_group_configurations" {
  command = plan

  variables {
    vnet_name                = "app-vnet"
    vnet_resource_group_name = "application-network-rg"
    nsg_name                 = "app-security-nsg"
    nsg_resource_group_name  = "application-security-rg"
    apim_subnet_prefix       = "10.1.5.0/24"
    location                 = "Central US"
    tags = {
      environment = "staging"
      application = "api-platform"
    }
    suffix = "stg001"
  }

  # Test that data sources reference the correct resource groups
  assert {
    condition     = data.azurerm_virtual_network.existing.resource_group_name == "application-network-rg"
    error_message = "Virtual network data source should reference the correct resource group"
  }

  assert {
    condition     = data.azurerm_network_security_group.existing.resource_group_name == "application-security-rg"
    error_message = "NSG data source should reference the correct resource group"
  }
}

run "test_comprehensive_tag_configurations" {
  command = plan

  variables {
    vnet_name                = "test-vnet"
    vnet_resource_group_name = "test-vnet-rg"
    nsg_name                 = "test-nsg"
    nsg_resource_group_name  = "test-nsg-rg"
    apim_subnet_prefix       = "10.0.1.0/24"
    location                 = "East US"
    tags = {
      environment           = "production"
      project              = "api-gateway-platform"
      team                 = "platform-engineering"
      cost-center          = "engineering"
      compliance           = "sox-compliant"
      backup-policy        = "daily"
      monitoring           = "enabled"
      security-level       = "high"
      data-classification  = "internal"
      business-unit        = "technology"
      owner                = "platform-team"
      created-by           = "terraform"
    }
    suffix = "prod001"
  }

  # Test that all tags are properly applied
  assert {
    condition = alltrue([
      for k, v in var.tags : azurerm_resource_group.this.tags[k] == v
    ])
    error_message = "All specified tags should be applied to the resource group"
  }

  assert {
    condition = alltrue([
      for k, v in var.tags : azurerm_api_management.this.tags[k] == v
    ])
    error_message = "All specified tags should be applied to the API Management instance"
  }
}

run "test_minimal_tag_configuration" {
  command = plan

  variables {
    vnet_name                = "test-vnet"
    vnet_resource_group_name = "test-vnet-rg"
    nsg_name                 = "test-nsg"
    nsg_resource_group_name  = "test-nsg-rg"
    apim_subnet_prefix       = "10.0.1.0/24"
    location                 = "East US"
    tags                     = {}  # Empty tags
    suffix                   = "min"
  }

  assert {
    condition     = azurerm_resource_group.this.name != null
    error_message = "Module should work with empty tags"
  }

  assert {
    condition     = azurerm_api_management.this.name != null
    error_message = "API Management should be created even with empty tags"
  }
}

run "test_various_suffix_patterns" {
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
    suffix = "x1y2z3"  # Mixed alphanumeric
  }

  assert {
    condition     = can(regex("x1y2z3", azurerm_resource_group.this.name))
    error_message = "Mixed alphanumeric suffix should be incorporated correctly"
  }
}

run "test_service_endpoints_configuration" {
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

  # Test that required service endpoints are configured
  assert {
    condition     = contains(azurerm_subnet.apim.service_endpoints, "Microsoft.Storage")
    error_message = "Subnet should have Microsoft.Storage service endpoint"
  }

  assert {
    condition     = contains(azurerm_subnet.apim.service_endpoints, "Microsoft.KeyVault")
    error_message = "Subnet should have Microsoft.KeyVault service endpoint"
  }

  assert {
    condition     = contains(azurerm_subnet.apim.service_endpoints, "Microsoft.Sql")
    error_message = "Subnet should have Microsoft.Sql service endpoint"
  }

  assert {
    condition     = contains(azurerm_subnet.apim.service_endpoints, "Microsoft.EventHub")
    error_message = "Subnet should have Microsoft.EventHub service endpoint"
  }

  assert {
    condition     = contains(azurerm_subnet.apim.service_endpoints, "Microsoft.ServiceBus")
    error_message = "Subnet should have Microsoft.ServiceBus service endpoint"
  }
}
