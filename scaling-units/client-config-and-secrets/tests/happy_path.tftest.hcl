run "test_module_scaffolding_exists" {
  command = plan

  variables {
    location      = "East US"
    vnet_name     = "test-vnet"
    subnet_name   = "test-subnet"
    suffix        = "test01"
    tags = {
      environment = "test"
    }
    vnet_resource_id   = "/subscriptions/test/resourceGroups/test/providers/Microsoft.Network/virtualNetworks/test-vnet"
    subnet_resource_id = "/subscriptions/test/resourceGroups/test/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/test-subnet"
  }

  assert {
    condition     = length(azurerm_resource_group.this.name) > 0
    error_message = "Resource group name must be generated"
  }
}

run "test_required_variables_defined" {
  command = plan

  variables {
    location          = "East US"
    vnet_name         = "test-vnet"
    vnet_resource_id  = "/subscriptions/test/resourceGroups/test/providers/Microsoft.Network/virtualNetworks/test-vnet"
    subnet_name       = "test-subnet"
    subnet_resource_id = "/subscriptions/test/resourceGroups/test/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/test-subnet"
    suffix            = "test01"
    tags = {
      environment = "test"
    }
  }

  assert {
    condition     = length(var.vnet_resource_id) > 0
    error_message = "VNET resource ID variable must be available"
  }

  assert {
    condition     = length(var.subnet_resource_id) > 0
    error_message = "Subnet resource ID variable must be available"
  }
}

run "test_happy_path_basic_configuration" {
  command = plan

  variables {
    location          = "East US"
    vnet_name         = "production-vnet"
    vnet_resource_id  = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/network-rg/providers/Microsoft.Network/virtualNetworks/production-vnet"
    subnet_name       = "private-endpoints"
    subnet_resource_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/network-rg/providers/Microsoft.Network/virtualNetworks/production-vnet/subnets/private-endpoints"
    suffix            = "prod01"
    tags = {
      Environment = "production"
      Project     = "client-onboarding"
      CostCenter  = "infrastructure"
    }
  }

  # Test resource group creation
  assert {
    condition     = azurerm_resource_group.this.location == "East US"
    error_message = "Resource group should be created in the specified location"
  }

  assert {
    condition     = azurerm_resource_group.this.tags["Environment"] == "production"
    error_message = "Resource group should have the specified tags"
  }

  # Test Key Vault configuration
  assert {
    condition     = azurerm_key_vault.this.sku_name == "standard"
    error_message = "Key Vault should use default standard SKU"
  }

  assert {
    condition     = azurerm_key_vault.this.public_network_access_enabled == false
    error_message = "Key Vault should have public network access disabled"
  }

  assert {
    condition     = azurerm_key_vault.this.soft_delete_retention_days == 7
    error_message = "Key Vault should have 7-day soft delete retention"
  }

  # Test App Configuration
  assert {
    condition     = azurerm_app_configuration.this.sku == "free"
    error_message = "App Configuration should use default free SKU"
  }

  assert {
    condition     = azurerm_app_configuration.this.public_network_access == "Disabled"
    error_message = "App Configuration should have public network access disabled"
  }

  # Test private DNS zones
  assert {
    condition     = azurerm_private_dns_zone.key_vault.name == "privatelink.vaultcore.azure.net"
    error_message = "Key Vault private DNS zone should use correct domain"
  }

  assert {
    condition     = azurerm_private_dns_zone.app_configuration.name == "privatelink.azconfig.io"
    error_message = "App Configuration private DNS zone should use correct domain"
  }

  # Test private endpoints
  assert {
    condition     = azurerm_private_endpoint.key_vault.subnet_id == var.subnet_resource_id
    error_message = "Key Vault private endpoint should be in the specified subnet"
  }

  assert {
    condition     = azurerm_private_endpoint.app_configuration.subnet_id == var.subnet_resource_id
    error_message = "App Configuration private endpoint should be in the specified subnet"
  }
}

run "test_happy_path_premium_configuration" {
  command = plan

  variables {
    location              = "West Europe"
    vnet_name             = "enterprise-vnet"
    vnet_resource_id      = "/subscriptions/87654321-4321-4321-4321-210987654321/resourceGroups/network-rg/providers/Microsoft.Network/virtualNetworks/enterprise-vnet"
    subnet_name           = "secure-endpoints"
    subnet_resource_id    = "/subscriptions/87654321-4321-4321-4321-210987654321/resourceGroups/network-rg/providers/Microsoft.Network/virtualNetworks/enterprise-vnet/subnets/secure-endpoints"
    suffix                = "ent01"
    key_vault_sku         = "premium"
    app_configuration_sku = "standard"
    tags = {
      Environment   = "production"
      SecurityLevel = "high"
      Compliance    = "required"
    }
  }

  # Test premium configuration
  assert {
    condition     = azurerm_key_vault.this.sku_name == "premium"
    error_message = "Key Vault should use premium SKU when specified"
  }

  assert {
    condition     = azurerm_app_configuration.this.sku == "standard"
    error_message = "App Configuration should use standard SKU when specified"
  }

  # Test location
  assert {
    condition     = azurerm_resource_group.this.location == "West Europe"
    error_message = "All resources should be created in the specified location"
  }

  # Test tags propagation
  assert {
    condition     = azurerm_key_vault.this.tags["SecurityLevel"] == "high"
    error_message = "Key Vault should inherit the specified tags"
  }

  assert {
    condition     = azurerm_app_configuration.this.tags["Compliance"] == "required"
    error_message = "App Configuration should inherit the specified tags"
  }
}
