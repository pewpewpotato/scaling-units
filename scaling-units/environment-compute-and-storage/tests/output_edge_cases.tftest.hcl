provider "azurerm" {
  features {}
  skip_provider_registration = true
}

run "test_no_missing_outputs" {
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

  # Test that all expected outputs are present (no missing outputs)
  assert {
    condition = alltrue([
      output.resource_group_name != null,
      output.resource_group_id != null,
      output.aca_environment_id != null,
      output.aca_environment_name != null,
      output.cosmos_db_account_id != null,
      output.cosmos_db_account_name != null,
      output.cosmos_db_account_endpoint != null,
      output.cosmos_db_primary_key != null,
      output.cosmos_db_secondary_key != null,
      output.cosmos_db_connection_strings != null,
      output.cosmos_db_private_endpoint_id != null,
      output.cosmos_db_private_endpoint_name != null,
      output.cosmos_db_private_dns_zone_id != null,
      output.cosmos_db_private_dns_zone_name != null,
      output.aca_nsg_id != null,
      output.aca_nsg_name != null,
      output.cosmos_nsg_id != null,
      output.cosmos_nsg_name != null,
      output.aca_nsg_subnet_association_id != null,
      output.cosmos_nsg_subnet_association_id != null,
      output.aca_nsg_inbound_rules != null,
      output.cosmos_nsg_inbound_rules != null
    ])
    error_message = "All expected outputs must be present - no missing outputs allowed"
  }
}

run "test_output_types_are_correct" {
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

  # Test that string outputs are not empty
  assert {
    condition = alltrue([
      length(output.resource_group_name) > 0,
      length(output.resource_group_id) > 0,
      length(output.aca_environment_id) > 0,
      length(output.aca_environment_name) > 0,
      length(output.cosmos_db_account_id) > 0,
      length(output.cosmos_db_account_name) > 0,
      length(output.cosmos_db_account_endpoint) > 0
    ])
    error_message = "String outputs must not be empty"
  }

  # Test that complex outputs have correct structure
  assert {
    condition = alltrue([
      can(output.cosmos_db_connection_strings.primary),
      can(output.cosmos_db_connection_strings.secondary)
    ])
    error_message = "Connection strings output must have primary and secondary keys"
  }

  assert {
    condition = length(output.aca_nsg_inbound_rules) == 2
    error_message = "ACA NSG should have exactly 2 inbound rules (HTTP and HTTPS)"
  }

  assert {
    condition = length(output.cosmos_nsg_inbound_rules) == 1
    error_message = "Cosmos DB NSG should have exactly 1 inbound rule (HTTPS)"
  }
}

run "test_edge_case_outputs_with_minimal_inputs" {
  command = plan

  variables {
    location                = "East US"
    tags                    = {}
    suffix                  = "x"
    aca_environment_sku     = "Consumption"
    aca_environment_subnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/aca"
    cosmos_db_sku           = "Free"
    vnet_core_subnet_id     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/core"
    vnet_id                 = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet"
  }

  # Test outputs still work with minimal/edge case inputs
  assert {
    condition = output.resource_group_name != null && output.resource_group_name != ""
    error_message = "Resource group name should be generated even with minimal inputs"
  }

  assert {
    condition = length(output.aca_nsg_inbound_rules) > 0
    error_message = "NSG rules should be created even with minimal inputs"
  }
}

run "test_output_consistency_across_resources" {
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

  # Test that related outputs are consistent
  assert {
    condition = can(regex("^/subscriptions/.*/resourceGroups/.*/providers/Microsoft.Resources/resourceGroups/.*", output.resource_group_id))
    error_message = "Resource group ID should follow Azure resource ID format"
  }

  assert {
    condition = can(regex("^/subscriptions/.*/resourceGroups/.*/providers/Microsoft.App/managedEnvironments/.*", output.aca_environment_id))
    error_message = "ACA Environment ID should follow Azure resource ID format"
  }

  assert {
    condition = can(regex("^/subscriptions/.*/resourceGroups/.*/providers/Microsoft.DocumentDB/databaseAccounts/.*", output.cosmos_db_account_id))
    error_message = "Cosmos DB Account ID should follow Azure resource ID format"
  }

  assert {
    condition = can(regex("^https://.*\\.documents\\.azure\\.com:443/", output.cosmos_db_account_endpoint))
    error_message = "Cosmos DB endpoint should be a valid HTTPS URL"
  }
}

run "test_no_reserved_or_invalid_output_names" {
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

  # This test ensures we don't have outputs with reserved or problematic names
  # All our current outputs follow good naming conventions
  assert {
    condition = alltrue([
      !can(output.password),        # No generic 'password' output
      !can(output.secret),          # No generic 'secret' output
      !can(output.key),             # No generic 'key' output
      !can(output.connection),      # No generic 'connection' output
      !can(output.id),              # No generic 'id' output
      !can(output.name)             # No generic 'name' output
    ])
    error_message = "Module should not expose outputs with reserved or generic names"
  }

  # Verify all output names are descriptive and specific
  assert {
    condition = alltrue([
      can(output.cosmos_db_primary_key),           # Specific key name
      can(output.cosmos_db_connection_strings),    # Specific connection strings
      can(output.resource_group_id),               # Specific ID
      can(output.aca_environment_name)             # Specific name
    ])
    error_message = "All outputs should have descriptive, specific names"
  }
}
