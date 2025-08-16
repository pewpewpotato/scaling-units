run "test_missing_location" {
  command = plan
  expect_failures = [var.location]

  variables {
    location           = ""
    vnet_name          = "test-vnet"
    vnet_resource_id   = "/subscriptions/test/resourceGroups/test/providers/Microsoft.Network/virtualNetworks/test-vnet"
    subnet_name        = "test-subnet"
    subnet_resource_id = "/subscriptions/test/resourceGroups/test/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/test-subnet"
    suffix             = "test01"
    tags = {
      environment = "test"
    }
  }
}

run "test_missing_vnet_name" {
  command = plan
  expect_failures = [var.vnet_name]

  variables {
    location           = "East US"
    vnet_name          = ""
    vnet_resource_id   = "/subscriptions/test/resourceGroups/test/providers/Microsoft.Network/virtualNetworks/test-vnet"
    subnet_name        = "test-subnet"
    subnet_resource_id = "/subscriptions/test/resourceGroups/test/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/test-subnet"
    suffix             = "test01"
    tags = {
      environment = "test"
    }
  }
}

run "test_missing_vnet_resource_id" {
  command = plan
  expect_failures = [var.vnet_resource_id]

  variables {
    location           = "East US"
    vnet_name          = "test-vnet"
    vnet_resource_id   = ""
    subnet_name        = "test-subnet"
    subnet_resource_id = "/subscriptions/test/resourceGroups/test/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/test-subnet"
    suffix             = "test01"
    tags = {
      environment = "test"
    }
  }
}

run "test_missing_subnet_name" {
  command = plan
  expect_failures = [var.subnet_name]

  variables {
    location           = "East US"
    vnet_name          = "test-vnet"
    vnet_resource_id   = "/subscriptions/test/resourceGroups/test/providers/Microsoft.Network/virtualNetworks/test-vnet"
    subnet_name        = ""
    subnet_resource_id = "/subscriptions/test/resourceGroups/test/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/test-subnet"
    suffix             = "test01"
    tags = {
      environment = "test"
    }
  }
}

run "test_missing_subnet_resource_id" {
  command = plan
  expect_failures = [var.subnet_resource_id]

  variables {
    location           = "East US"
    vnet_name          = "test-vnet"
    vnet_resource_id   = "/subscriptions/test/resourceGroups/test/providers/Microsoft.Network/virtualNetworks/test-vnet"
    subnet_name        = "test-subnet"
    subnet_resource_id = ""
    suffix             = "test01"
    tags = {
      environment = "test"
    }
  }
}

run "test_invalid_suffix_too_long" {
  command = plan
  expect_failures = [var.suffix]

  variables {
    location           = "East US"
    vnet_name          = "test-vnet"
    vnet_resource_id   = "/subscriptions/test/resourceGroups/test/providers/Microsoft.Network/virtualNetworks/test-vnet"
    subnet_name        = "test-subnet"
    subnet_resource_id = "/subscriptions/test/resourceGroups/test/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/test-subnet"
    suffix             = "thisismuchlongerthan10characters"
    tags = {
      environment = "test"
    }
  }
}

run "test_invalid_suffix_empty" {
  command = plan
  expect_failures = [var.suffix]

  variables {
    location           = "East US"
    vnet_name          = "test-vnet"
    vnet_resource_id   = "/subscriptions/test/resourceGroups/test/providers/Microsoft.Network/virtualNetworks/test-vnet"
    subnet_name        = "test-subnet"
    subnet_resource_id = "/subscriptions/test/resourceGroups/test/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/test-subnet"
    suffix             = ""
    tags = {
      environment = "test"
    }
  }
}

run "test_invalid_suffix_special_characters" {
  command = plan
  expect_failures = [var.suffix]

  variables {
    location           = "East US"
    vnet_name          = "test-vnet"
    vnet_resource_id   = "/subscriptions/test/resourceGroups/test/providers/Microsoft.Network/virtualNetworks/test-vnet"
    subnet_name        = "test-subnet"
    subnet_resource_id = "/subscriptions/test/resourceGroups/test/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/test-subnet"
    suffix             = "test-01!"
    tags = {
      environment = "test"
    }
  }
}

run "test_invalid_key_vault_sku" {
  command = plan
  expect_failures = [var.key_vault_sku]

  variables {
    location           = "East US"
    vnet_name          = "test-vnet"
    vnet_resource_id   = "/subscriptions/test/resourceGroups/test/providers/Microsoft.Network/virtualNetworks/test-vnet"
    subnet_name        = "test-subnet"
    subnet_resource_id = "/subscriptions/test/resourceGroups/test/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/test-subnet"
    suffix             = "test01"
    key_vault_sku      = "invalid"
    tags = {
      environment = "test"
    }
  }
}

run "test_invalid_app_configuration_sku" {
  command = plan
  expect_failures = [var.app_configuration_sku]

  variables {
    location              = "East US"
    vnet_name             = "test-vnet"
    vnet_resource_id      = "/subscriptions/test/resourceGroups/test/providers/Microsoft.Network/virtualNetworks/test-vnet"
    subnet_name           = "test-subnet"
    subnet_resource_id    = "/subscriptions/test/resourceGroups/test/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/test-subnet"
    suffix                = "test01"
    app_configuration_sku = "invalid"
    tags = {
      environment = "test"
    }
  }
}
