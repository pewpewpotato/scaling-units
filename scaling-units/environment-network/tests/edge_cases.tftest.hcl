run "test_edge_case_minimal_vnet" {
  command = plan

  variables {
    location           = "East US"
    vnet_address_space = "10.0.0.0/30"
    core_subnet_prefix = "10.0.0.0/30"
    tags = {
      environment = "test"
    }
    suffix = "min01"
  }
}

run "test_edge_case_maximum_vnet" {
  command = plan

  variables {
    location           = "East US"
    vnet_address_space = "10.0.0.0/8"
    core_subnet_prefix = "10.1.0.0/16"
    tags = {
      environment = "test"
    }
    suffix = "max01"
  }
}

run "test_edge_case_overlapping_subnets_should_fail" {
  command = plan

  variables {
    location           = "East US"
    vnet_address_space = "10.0.0.0/24"
    core_subnet_prefix = "10.0.1.0/24"
    tags = {
      environment = "test"
    }
    suffix = "test01"
  }

  # This should potentially fail during plan due to subnet not fitting in VNet
}

run "test_edge_case_very_long_suffix" {
  command = plan

  variables {
    location           = "East US"
    vnet_address_space = "10.0.0.0/16"
    core_subnet_prefix = "10.0.1.0/24"
    tags = {
      environment = "test"
    }
    suffix = "12345678901"  # 11 characters, should fail
  }

  expect_failures = [
    var.suffix,
  ]
}
