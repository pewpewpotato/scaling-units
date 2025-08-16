run "test_configurable_minimal_inputs" {
  command = plan

  variables {
    location           = "eastus"  # Minimal valid Azure region name
    vnet_name          = "v"       # Minimal valid name
    vnet_resource_id   = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/r/providers/Microsoft.Network/virtualNetworks/v"
    subnet_name        = "s"       # Minimal valid name
    subnet_resource_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/r/providers/Microsoft.Network/virtualNetworks/v/subnets/s"
    suffix             = "a"       # Minimal suffix (1 character)
    key_vault_sku      = "standard"
    app_configuration_sku = "free"
    tags = {
      env = "t"  # Minimal tag
    }
  }

  assert {
    condition     = azurerm_resource_group.this.location == "eastus"
    error_message = "Minimal location should be accepted"
  }

  assert {
    condition     = azurerm_key_vault.this.sku_name == "standard"
    error_message = "Standard Key Vault SKU should be configured"
  }

  assert {
    condition     = azurerm_app_configuration.this.sku == "free"
    error_message = "Free App Configuration SKU should be configured"
  }
}

run "test_configurable_maximal_inputs" {
  command = plan

  variables {
    location           = "West Europe"  # Longer location name
    vnet_name          = "production-enterprise-virtual-network-with-very-long-name"
    vnet_resource_id   = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/very-long-resource-group-name-for-production-enterprise/providers/Microsoft.Network/virtualNetworks/production-enterprise-virtual-network-with-very-long-name"
    subnet_name        = "private-endpoints-subnet-for-secure-communication"
    subnet_resource_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/very-long-resource-group-name-for-production-enterprise/providers/Microsoft.Network/virtualNetworks/production-enterprise-virtual-network-with-very-long-name/subnets/private-endpoints-subnet-for-secure-communication"
    suffix             = "1234567890"  # Maximum suffix length (10 characters)
    key_vault_sku      = "premium"
    app_configuration_sku = "standard"
    tags = {
      Environment             = "production"
      CostCenter             = "infrastructure-team-cost-center"
      Owner                  = "platform-engineering-team"
      Project                = "enterprise-client-onboarding-initiative"
      SecurityClassification = "confidential"
      DataRetention          = "7-years"
      BackupFrequency        = "daily"
      MonitoringLevel        = "enhanced"
      ComplianceFramework    = "iso27001-sox-gdpr"
      BusinessUnit           = "enterprise-solutions-division"
    }
  }

  assert {
    condition     = azurerm_resource_group.this.location == "West Europe"
    error_message = "Maximal location should be accepted"
  }

  assert {
    condition     = azurerm_key_vault.this.sku_name == "premium"
    error_message = "Premium Key Vault SKU should be configured"
  }

  assert {
    condition     = azurerm_app_configuration.this.sku == "standard"
    error_message = "Standard App Configuration SKU should be configured"
  }

  assert {
    condition     = length(var.suffix) == 10
    error_message = "Maximum suffix length should be accepted"
  }

  assert {
    condition     = length(var.tags) == 10
    error_message = "Multiple tags should be configured"
  }

  assert {
    condition     = azurerm_key_vault.this.tags["Environment"] == "production"
    error_message = "Tags should be propagated to Key Vault"
  }

  assert {
    condition     = azurerm_app_configuration.this.tags["SecurityClassification"] == "confidential"
    error_message = "Tags should be propagated to App Configuration"
  }
}

run "test_configurable_different_regions" {
  command = plan

  variables {
    location           = "Australia East"
    vnet_name          = "australia-vnet"
    vnet_resource_id   = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/australia-rg/providers/Microsoft.Network/virtualNetworks/australia-vnet"
    subnet_name        = "australia-subnet"
    subnet_resource_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/australia-rg/providers/Microsoft.Network/virtualNetworks/australia-vnet/subnets/australia-subnet"
    suffix             = "au01"
    tags = {
      region = "apac"
    }
  }

  assert {
    condition     = azurerm_resource_group.this.location == "Australia East"
    error_message = "Different Azure regions should be supported"
  }

  assert {
    condition     = azurerm_key_vault.this.location == "Australia East"
    error_message = "Key Vault should be created in the specified region"
  }

  assert {
    condition     = azurerm_app_configuration.this.location == "Australia East"
    error_message = "App Configuration should be created in the specified region"
  }
}

run "test_configurable_sku_combinations" {
  command = plan

  variables {
    location              = "North Europe"
    vnet_name             = "europe-vnet"
    vnet_resource_id      = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/europe-rg/providers/Microsoft.Network/virtualNetworks/europe-vnet"
    subnet_name           = "europe-subnet"
    subnet_resource_id    = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/europe-rg/providers/Microsoft.Network/virtualNetworks/europe-vnet/subnets/europe-subnet"
    suffix                = "eu01"
    key_vault_sku         = "premium"    # Premium KV
    app_configuration_sku = "free"       # Free App Config
    tags = {
      sku_test = "mixed"
    }
  }

  assert {
    condition     = azurerm_key_vault.this.sku_name == "premium"
    error_message = "Premium Key Vault SKU should be configurable"
  }

  assert {
    condition     = azurerm_app_configuration.this.sku == "free"
    error_message = "Free App Configuration SKU should be configurable"
  }
}

run "test_configurable_resource_id_formats" {
  command = plan

  variables {
    location           = "Central US"
    vnet_name          = "format-test-vnet"
    # Test with different subscription ID format
    vnet_resource_id   = "/subscriptions/87654321-4321-4321-4321-210987654321/resourceGroups/different-rg/providers/Microsoft.Network/virtualNetworks/format-test-vnet"
    subnet_name        = "format-test-subnet"
    subnet_resource_id = "/subscriptions/87654321-4321-4321-4321-210987654321/resourceGroups/different-rg/providers/Microsoft.Network/virtualNetworks/format-test-vnet/subnets/format-test-subnet"
    suffix             = "fmt01"
    tags = {
      test_type = "format"
    }
  }

  assert {
    condition     = azurerm_private_endpoint.key_vault.subnet_id == var.subnet_resource_id
    error_message = "Different resource ID formats should be handled"
  }

  assert {
    condition     = azurerm_private_endpoint.app_configuration.subnet_id == var.subnet_resource_id
    error_message = "Subnet resource ID should be correctly referenced"
  }

  assert {
    condition     = azurerm_private_dns_zone_virtual_network_link.key_vault.virtual_network_id == var.vnet_resource_id
    error_message = "VNET resource ID should be correctly referenced"
  }
}
