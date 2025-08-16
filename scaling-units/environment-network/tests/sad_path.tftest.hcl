run "test_missing_location" {
  command = plan

  variables {
    vnet_address_space = "10.0.0.0/16"
    core_subnet_prefix = "10.0.1.0/24"
    tags = {
      environment = "test"
    }
    suffix = "test01"
  }

  # Should fail due to missing required variable
}

run "test_missing_vnet_address_space" {
  command = plan

  variables {
    location           = "East US"
    core_subnet_prefix = "10.0.1.0/24"
    tags = {
      environment = "test"
    }
    suffix = "test01"
  }

  # Should fail due to missing required variable
}

run "test_missing_core_subnet_prefix" {
  command = plan

  variables {
    location           = "East US"
    vnet_address_space = "10.0.0.0/16"
    tags = {
      environment = "test"
    }
    suffix = "test01"
  }

  # Should fail due to missing required variable
}

run "test_missing_tags" {
  command = plan

  variables {
    location           = "East US"
    vnet_address_space = "10.0.0.0/16"
    core_subnet_prefix = "10.0.1.0/24"
    suffix = "test01"
  }

  # Should fail due to missing required variable
}

run "test_missing_suffix" {
  command = plan

  variables {
    location           = "East US"
    vnet_address_space = "10.0.0.0/16"
    core_subnet_prefix = "10.0.1.0/24"
    tags = {
      environment = "test"
    }
  }

  # Should fail due to missing required variable
}
