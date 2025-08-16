run "test_variable_validation" {
  command = plan

  variables {
    location           = "East US"
    vnet_address_space = "10.0.0.0/16"
    core_subnet_prefix = "10.0.1.0/24"
    tags = {
      environment = "test"
    }
    suffix = "test01"
  }
}

run "test_invalid_vnet_cidr" {
  command = plan

  variables {
    location           = "East US"
    vnet_address_space = "invalid-cidr"
    core_subnet_prefix = "10.0.1.0/24"
    tags = {
      environment = "test"
    }
    suffix = "test01"
  }

  expect_failures = [
    var.vnet_address_space,
  ]
}

run "test_invalid_subnet_cidr" {
  command = plan

  variables {
    location           = "East US"
    vnet_address_space = "10.0.0.0/16"
    core_subnet_prefix = "invalid-cidr"
    tags = {
      environment = "test"
    }
    suffix = "test01"
  }

  expect_failures = [
    var.core_subnet_prefix,
  ]
}

run "test_empty_location" {
  command = plan

  variables {
    location           = ""
    vnet_address_space = "10.0.0.0/16"
    core_subnet_prefix = "10.0.1.0/24"
    tags = {
      environment = "test"
    }
    suffix = "test01"
  }

  expect_failures = [
    var.location,
  ]
}

run "test_invalid_suffix" {
  command = plan

  variables {
    location           = "East US"
    vnet_address_space = "10.0.0.0/16"
    core_subnet_prefix = "10.0.1.0/24"
    tags = {
      environment = "test"
    }
    suffix = "invalid-suffix-with-hyphens"
  }

  expect_failures = [
    var.suffix,
  ]
}
