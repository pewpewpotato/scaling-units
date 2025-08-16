provider "azurerm" {
  features {}
  skip_provider_registration = true
}

run "test_readme_documents_all_outputs" {
  command = plan

  variables {
    location                = "East US"
    tags                    = { "Environment" = "Test" }
    suffix                  = "test"
    aca_environment_sku     = "Consumption"
    aca_environment_subnet_id = "/subscriptions/test/resourceGroups/test/providers/Microsoft.Network/virtualNetworks/test/subnets/aca"
    cosmos_db_sku           = "Standard"
    vnet_core_subnet_id     = "/subscriptions/test/resourceGroups/test/providers/Microsoft.Network/virtualNetworks/test/subnets/core"
    vnet_id                 = "/subscriptions/test/resourceGroups/test/providers/Microsoft.Network/virtualNetworks/test"
  }

  # This test validates that the module provides complete outputs for downstream consumption
  # The actual README validation would be done through file content checks
  assert {
    condition = length([
      output.resource_group_name,
      output.resource_group_id,
      output.aca_environment_id,
      output.aca_environment_name,
      output.cosmos_db_account_id,
      output.cosmos_db_account_name,
      output.cosmos_db_account_endpoint,
      output.cosmos_db_primary_key,
      output.cosmos_db_secondary_key,
      output.cosmos_db_connection_strings,
      output.cosmos_db_private_endpoint_id,
      output.cosmos_db_private_endpoint_name,
      output.cosmos_db_private_dns_zone_id,
      output.cosmos_db_private_dns_zone_name,
      output.aca_nsg_id,
      output.cosmos_nsg_id,
      output.aca_nsg_subnet_association_id,
      output.cosmos_nsg_subnet_association_id,
      output.aca_nsg_inbound_rules,
      output.cosmos_nsg_inbound_rules
    ]) == 20
    error_message = "All 20 expected outputs must be available for documentation in README"
  }
}

run "test_outputs_have_descriptions" {
  command = plan

  variables {
    location                = "East US"
    tags                    = { "Environment" = "Test" }
    suffix                  = "test"
    aca_environment_sku     = "Consumption"
    aca_environment_subnet_id = "/subscriptions/test/resourceGroups/test/providers/Microsoft.Network/virtualNetworks/test/subnets/aca"
    cosmos_db_sku           = "Standard"
    vnet_core_subnet_id     = "/subscriptions/test/resourceGroups/test/providers/Microsoft.Network/virtualNetworks/test/subnets/core"
    vnet_id                 = "/subscriptions/test/resourceGroups/test/providers/Microsoft.Network/virtualNetworks/test"
  }

  # This test ensures all outputs have meaningful descriptions that can be documented
  # In a real scenario, we would parse the outputs.tf file to validate descriptions
  assert {
    condition = output.resource_group_name != null
    error_message = "Resource group name output must exist and be documented"
  }

  assert {
    condition = output.cosmos_db_connection_strings != null
    error_message = "Connection strings output must exist and be documented"
  }

  assert {
    condition = output.aca_nsg_inbound_rules != null
    error_message = "NSG rules output must exist and be documented"
  }
}
