# Test for Environment Compute and Storage Module - Happy Path Tests

provider "azurerm" {
  features {}
  skip_provider_registration = true
}

run "test_accepts_aca_environment_sku_and_subnet_inputs" {
  command = plan

  variables {
    location = "East US"
    tags = {
      environment = "test"
      project     = "environment-compute-and-storage"
    }
    suffix = "001"
    aca_environment_sku = "Consumption"
    aca_environment_subnet_id = "/subscriptions/test-sub/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/aca-subnet"
    cosmos_db_sku = "Standard"
    vnet_core_subnet_id = "/subscriptions/test-sub/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/core-subnet"
  }

  assert {
    condition     = length(var.aca_environment_sku) > 0
    error_message = "ACA Environment SKU should be accepted as input"
  }

  assert {
    condition     = length(var.aca_environment_subnet_id) > 0
    error_message = "ACA Environment subnet ID should be accepted as input"
  }
}

run "test_aca_environment_created_in_specified_subnet" {
  command = plan

  variables {
    location = "East US"
    tags = {
      environment = "test"
      project     = "environment-compute-and-storage"
    }
    suffix = "001"
    aca_environment_sku = "Consumption"
    aca_environment_subnet_id = "/subscriptions/test-sub/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/aca-subnet"
    cosmos_db_sku = "Standard"
    vnet_core_subnet_id = "/subscriptions/test-sub/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/core-subnet"
  }

  assert {
    condition     = azurerm_container_app_environment.this.infrastructure_subnet_id == "/subscriptions/test-sub/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/aca-subnet"
    error_message = "ACA Environment should be created in the specified subnet"
  }
}

run "test_aca_environment_follows_azure_naming_standards" {
  command = plan

  variables {
    location = "East US"
    tags = {
      environment = "test"
      project     = "environment-compute-and-storage"
    }
    suffix = "001"
    aca_environment_sku = "Consumption"
    aca_environment_subnet_id = "/subscriptions/test-sub/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/aca-subnet"
    cosmos_db_sku = "Standard"
    vnet_core_subnet_id = "/subscriptions/test-sub/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/core-subnet"
  }

  assert {
    condition     = azurerm_container_app_environment.this.name == module.naming.container_app_environment.name
    error_message = "ACA Environment name should follow Azure naming standards from azure/naming module"
  }

  assert {
    condition     = can(regex("^cae-", azurerm_container_app_environment.this.name))
    error_message = "ACA Environment name should start with 'cae-' prefix according to Azure naming standards"
  }
}

run "test_accepts_cosmos_db_sku_input" {
  command = plan

  variables {
    location = "East US"
    tags = {
      environment = "test"
      project     = "environment-compute-and-storage"
    }
    suffix = "001"
    aca_environment_sku = "Consumption"
    aca_environment_subnet_id = "/subscriptions/test-sub/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/aca-subnet"
    cosmos_db_sku = "Standard"
    vnet_core_subnet_id = "/subscriptions/test-sub/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/core-subnet"
  }

  assert {
    condition     = length(var.cosmos_db_sku) > 0
    error_message = "Cosmos DB SKU should be accepted as input"
  }
}

run "test_cosmos_db_created_with_specified_sku" {
  command = plan

  variables {
    location = "East US"
    tags = {
      environment = "test"
      project     = "environment-compute-and-storage"
    }
    suffix = "001"
    aca_environment_sku = "Consumption"
    aca_environment_subnet_id = "/subscriptions/test-sub/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/aca-subnet"
    cosmos_db_sku = "Standard"
    vnet_core_subnet_id = "/subscriptions/test-sub/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/core-subnet"
  }

  assert {
    condition     = azurerm_cosmosdb_account.this.offer_type == "Standard"
    error_message = "Cosmos DB Account should be created with the specified SKU"
  }
}

run "test_cosmos_db_follows_azure_naming_standards" {
  command = plan

  variables {
    location = "East US"
    tags = {
      environment = "test"
      project     = "environment-compute-and-storage"
    }
    suffix = "001"
    aca_environment_sku = "Consumption"
    aca_environment_subnet_id = "/subscriptions/test-sub/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/aca-subnet"
    cosmos_db_sku = "Standard"
    vnet_core_subnet_id = "/subscriptions/test-sub/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/core-subnet"
  }

  assert {
    condition     = azurerm_cosmosdb_account.this.name == module.naming.cosmosdb_account.name
    error_message = "Cosmos DB Account name should follow Azure naming standards from azure/naming module"
  }

  assert {
    condition     = can(regex("^cosmos-", azurerm_cosmosdb_account.this.name))
    error_message = "Cosmos DB Account name should start with 'cosmos-' prefix according to Azure naming standards"
  }
}

run "test_cosmos_db_private_endpoint_created" {
  command = plan

  variables {
    location = "East US"
    tags = {
      environment = "test"
      project     = "environment-compute-and-storage"
    }
    suffix = "001"
    aca_environment_sku = "Consumption"
    aca_environment_subnet_id = "/subscriptions/test-sub/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/aca-subnet"
    cosmos_db_sku = "Standard"
    vnet_core_subnet_id = "/subscriptions/test-sub/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/core-subnet"
  }

  assert {
    condition     = azurerm_private_endpoint.cosmos_db.subnet_id == "/subscriptions/test-sub/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/core-subnet"
    error_message = "Cosmos DB private endpoint should be created in the VNET core subnet"
  }

  assert {
    condition     = length(azurerm_private_endpoint.cosmos_db.private_service_connection) > 0
    error_message = "Cosmos DB private endpoint should have a private service connection"
  }
}
