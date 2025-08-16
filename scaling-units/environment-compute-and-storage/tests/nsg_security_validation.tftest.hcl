provider "azurerm" {
  features {}
  skip_provider_registration = true
}

run "test_nsg_aca_only_required_ports_open" {
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
    condition = length([
      for rule in output.aca_nsg_inbound_rules :
      rule if rule.destination_port_range == "80" || rule.destination_port_range == "443"
    ]) == 2
    error_message = "ACA NSG should only have rules for ports 80 and 443"
  }

  assert {
    condition = length([
      for rule in output.aca_nsg_inbound_rules :
      rule if !(rule.destination_port_range == "80" || rule.destination_port_range == "443")
    ]) == 0
    error_message = "ACA NSG contains unauthorized ports beyond 80 and 443"
  }
}

run "test_nsg_cosmos_only_required_ports_open" {
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
    condition = length([
      for rule in output.cosmos_nsg_inbound_rules :
      rule if rule.destination_port_range == "443"
    ]) == 1
    error_message = "Cosmos DB NSG should only have rule for port 443"
  }

  assert {
    condition = length([
      for rule in output.cosmos_nsg_inbound_rules :
      rule if rule.destination_port_range != "443"
    ]) == 0
    error_message = "Cosmos DB NSG contains unauthorized ports beyond 443"
  }
}

run "test_all_nsg_rules_documented_in_outputs" {
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
    condition = output.aca_nsg_id != null && output.aca_nsg_id != ""
    error_message = "ACA NSG ID must be documented in outputs"
  }

  assert {
    condition = output.cosmos_nsg_id != null && output.cosmos_nsg_id != ""
    error_message = "Cosmos DB NSG ID must be documented in outputs"
  }

  assert {
    condition = length(output.aca_nsg_inbound_rules) > 0
    error_message = "All ACA NSG inbound rules must be documented in outputs"
  }

  assert {
    condition = length(output.cosmos_nsg_inbound_rules) > 0
    error_message = "All Cosmos DB NSG inbound rules must be documented in outputs"
  }

  assert {
    condition = output.aca_nsg_subnet_association_id != null && output.aca_nsg_subnet_association_id != ""
    error_message = "ACA NSG subnet association must be documented in outputs"
  }

  assert {
    condition = output.cosmos_nsg_subnet_association_id != null && output.cosmos_nsg_subnet_association_id != ""
    error_message = "Cosmos DB NSG subnet association must be documented in outputs"
  }
}

run "test_nsg_rules_have_required_properties" {
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
    condition = alltrue([
      for rule in output.aca_nsg_inbound_rules :
      rule.name != null && rule.priority != null && rule.direction != null && rule.access != null && rule.protocol != null && rule.source_port_range != null && rule.destination_port_range != null && rule.source_address_prefix != null && rule.destination_address_prefix != null
    ])
    error_message = "All ACA NSG rules must have complete property documentation"
  }

  assert {
    condition = alltrue([
      for rule in output.cosmos_nsg_inbound_rules :
      rule.name != null && rule.priority != null && rule.direction != null && rule.access != null && rule.protocol != null && rule.source_port_range != null && rule.destination_port_range != null && rule.source_address_prefix != null && rule.destination_address_prefix != null
    ])
    error_message = "All Cosmos DB NSG rules must have complete property documentation"
  }
}
