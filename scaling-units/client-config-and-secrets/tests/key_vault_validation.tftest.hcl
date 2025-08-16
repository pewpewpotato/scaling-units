run "test_key_vault_creation" {
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
    condition     = azurerm_key_vault.this.sku_name == "standard"
    error_message = "Key Vault should be created with standard SKU by default"
  }

  assert {
    condition     = length(azurerm_private_endpoint.key_vault.name) > 0
    error_message = "Key Vault private endpoint should be created"
  }

  assert {
    condition     = length(azurerm_private_dns_zone.key_vault.name) > 0
    error_message = "Key Vault private DNS zone should be created"
  }
}
