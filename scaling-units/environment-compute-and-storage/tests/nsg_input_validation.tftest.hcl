provider "azurerm" {
  features {}
  skip_provider_registration = true
}

run "test_nsg_rules_when_invalid_subnet_ids" {
  command = plan

  variables {
    location                = "East US"
    tags                    = { "Environment" = "Test" }
    suffix                  = "test"
    aca_environment_sku     = "Consumption"
    aca_environment_subnet_id = "invalid-subnet-id"
    cosmos_db_sku           = "Standard"
    vnet_core_subnet_id     = "invalid-subnet-id"
    vnet_id                 = "invalid-vnet-id"
  }

  expect_failures = [
    var.aca_environment_subnet_id,
    var.vnet_core_subnet_id,
    var.vnet_id
  ]
}

run "test_nsg_rules_require_valid_aca_subnet" {
  command = plan

  variables {
    location                = "East US"
    tags                    = { "Environment" = "Test" }
    suffix                  = "test"
    aca_environment_sku     = "Consumption"
    aca_environment_subnet_id = ""
    cosmos_db_sku           = "Standard"
    vnet_core_subnet_id     = "/subscriptions/test/resourceGroups/test/providers/Microsoft.Network/virtualNetworks/test/subnets/core"
    vnet_id                 = "/subscriptions/test/resourceGroups/test/providers/Microsoft.Network/virtualNetworks/test"
  }

  expect_failures = [
    var.aca_environment_subnet_id
  ]
}

run "test_nsg_rules_require_valid_core_subnet" {
  command = plan

  variables {
    location                = "East US"
    tags                    = { "Environment" = "Test" }
    suffix                  = "test"
    aca_environment_sku     = "Consumption"
    aca_environment_subnet_id = "/subscriptions/test/resourceGroups/test/providers/Microsoft.Network/virtualNetworks/test/subnets/aca"
    cosmos_db_sku           = "Standard"
    vnet_core_subnet_id     = ""
    vnet_id                 = "/subscriptions/test/resourceGroups/test/providers/Microsoft.Network/virtualNetworks/test"
  }

  expect_failures = [
    var.vnet_core_subnet_id
  ]
}

run "test_nsg_rules_require_valid_vnet_id" {
  command = plan

  variables {
    location                = "East US"
    tags                    = { "Environment" = "Test" }
    suffix                  = "test"
    aca_environment_sku     = "Consumption"
    aca_environment_subnet_id = "/subscriptions/test/resourceGroups/test/providers/Microsoft.Network/virtualNetworks/test/subnets/aca"
    cosmos_db_sku           = "Standard"
    vnet_core_subnet_id     = "/subscriptions/test/resourceGroups/test/providers/Microsoft.Network/virtualNetworks/test/subnets/core"
    vnet_id                 = ""
  }

  expect_failures = [
    var.vnet_id
  ]
}

run "test_nsg_rules_created_with_valid_inputs" {
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
    error_message = "ACA NSG should be created with valid inputs"
  }

  assert {
    condition = output.cosmos_nsg_id != null && output.cosmos_nsg_id != ""
    error_message = "Cosmos DB NSG should be created with valid inputs"
  }

  assert {
    condition = output.aca_nsg_subnet_association_id != null && output.aca_nsg_subnet_association_id != ""
    error_message = "ACA NSG subnet association should be created with valid inputs"
  }

  assert {
    condition = output.cosmos_nsg_subnet_association_id != null && output.cosmos_nsg_subnet_association_id != ""
    error_message = "Cosmos DB NSG subnet association should be created with valid inputs"
  }
}
