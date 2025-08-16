run "test_output_validation" {
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

  # Test that all Key Vault outputs are available
  assert {
    condition     = output.key_vault_id != ""
    error_message = "Key Vault ID output must be available"
  }

  assert {
    condition     = output.key_vault_name != ""
    error_message = "Key Vault name output must be available"
  }

  assert {
    condition     = output.key_vault_uri != ""
    error_message = "Key Vault URI output must be available"
  }

  assert {
    condition     = output.key_vault_private_endpoint_id != ""
    error_message = "Key Vault private endpoint ID output must be available"
  }

  assert {
    condition     = output.key_vault_private_dns_zone_name != ""
    error_message = "Key Vault private DNS zone name output must be available"
  }

  # Test that all App Configuration outputs are available
  assert {
    condition     = output.app_configuration_id != ""
    error_message = "App Configuration ID output must be available"
  }

  assert {
    condition     = output.app_configuration_name != ""
    error_message = "App Configuration name output must be available"
  }

  assert {
    condition     = output.app_configuration_endpoint != ""
    error_message = "App Configuration endpoint output must be available"
  }

  assert {
    condition     = output.app_configuration_private_endpoint_id != ""
    error_message = "App Configuration private endpoint ID output must be available"
  }

  assert {
    condition     = output.app_configuration_private_dns_zone_name != ""
    error_message = "App Configuration private DNS zone name output must be available"
  }

  # Test that resource group outputs are available
  assert {
    condition     = output.resource_group_id != ""
    error_message = "Resource group ID output must be available"
  }

  assert {
    condition     = output.resource_group_name != ""
    error_message = "Resource group name output must be available"
  }
}
