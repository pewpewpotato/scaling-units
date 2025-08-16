run "test_app_configuration_creation" {
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
    condition     = azurerm_app_configuration.this.sku == "free"
    error_message = "App Configuration should be created with free SKU by default"
  }

  assert {
    condition     = length(azurerm_private_endpoint.app_configuration.name) > 0
    error_message = "App Configuration private endpoint should be created"
  }

  assert {
    condition     = length(azurerm_private_dns_zone.app_configuration.name) > 0
    error_message = "App Configuration private DNS zone should be created"
  }
}
