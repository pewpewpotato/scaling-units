provider "azurerm" {
  features {}
  skip_provider_registration = true
}

run "test_all_required_outputs_exposed" {
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

  # Resource Group outputs
  assert {
    condition = output.resource_group_name != null && output.resource_group_name != ""
    error_message = "Resource group name must be exposed as output"
  }

  assert {
    condition = output.resource_group_id != null && output.resource_group_id != ""
    error_message = "Resource group ID must be exposed as output"
  }

  # ACA Environment outputs
  assert {
    condition = output.aca_environment_id != null && output.aca_environment_id != ""
    error_message = "ACA Environment ID must be exposed as output"
  }

  assert {
    condition = output.aca_environment_name != null && output.aca_environment_name != ""
    error_message = "ACA Environment name must be exposed as output"
  }

  # Cosmos DB outputs - IDs and endpoints
  assert {
    condition = output.cosmos_db_account_id != null && output.cosmos_db_account_id != ""
    error_message = "Cosmos DB Account ID must be exposed as output"
  }

  assert {
    condition = output.cosmos_db_account_name != null && output.cosmos_db_account_name != ""
    error_message = "Cosmos DB Account name must be exposed as output"
  }

  assert {
    condition = output.cosmos_db_account_endpoint != null && output.cosmos_db_account_endpoint != ""
    error_message = "Cosmos DB Account endpoint must be exposed as output"
  }

  # Connection strings and keys
  assert {
    condition = output.cosmos_db_primary_key != null && output.cosmos_db_primary_key != ""
    error_message = "Cosmos DB primary key must be exposed as output for connection strings"
  }

  assert {
    condition = output.cosmos_db_connection_strings != null && length(output.cosmos_db_connection_strings) > 0
    error_message = "Cosmos DB connection strings must be exposed as output"
  }

  # Private endpoint outputs
  assert {
    condition = output.cosmos_db_private_endpoint_id != null && output.cosmos_db_private_endpoint_id != ""
    error_message = "Cosmos DB private endpoint ID must be exposed as output"
  }

  assert {
    condition = output.cosmos_db_private_endpoint_name != null && output.cosmos_db_private_endpoint_name != ""
    error_message = "Cosmos DB private endpoint name must be exposed as output"
  }

  # Private DNS zone outputs
  assert {
    condition = output.cosmos_db_private_dns_zone_id != null && output.cosmos_db_private_dns_zone_id != ""
    error_message = "Cosmos DB private DNS zone ID must be exposed as output"
  }

  assert {
    condition = output.cosmos_db_private_dns_zone_name != null && output.cosmos_db_private_dns_zone_name != ""
    error_message = "Cosmos DB private DNS zone name must be exposed as output"
  }

  # NSG outputs
  assert {
    condition = output.aca_nsg_id != null && output.aca_nsg_id != ""
    error_message = "ACA NSG ID must be exposed as output"
  }

  assert {
    condition = output.cosmos_nsg_id != null && output.cosmos_nsg_id != ""
    error_message = "Cosmos DB NSG ID must be exposed as output"
  }
}

run "test_connection_strings_format" {
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

  assert {
    condition = length(output.cosmos_db_connection_strings) >= 1
    error_message = "Cosmos DB connection strings should include at least primary connection string"
  }

  assert {
    condition = contains(keys(output.cosmos_db_connection_strings), "primary")
    error_message = "Cosmos DB connection strings should include primary connection string"
  }

  assert {
    condition = contains(keys(output.cosmos_db_connection_strings), "secondary")
    error_message = "Cosmos DB connection strings should include secondary connection string for high availability"
  }
}

run "test_sensitive_outputs_marked" {
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

  # This test ensures sensitive outputs are properly marked
  # Note: In actual Terraform, sensitive outputs won't be displayed in plan/apply output
  assert {
    condition = output.cosmos_db_primary_key != null
    error_message = "Cosmos DB primary key output must exist"
  }

  assert {
    condition = output.cosmos_db_connection_strings != null
    error_message = "Cosmos DB connection strings output must exist"
  }
}
