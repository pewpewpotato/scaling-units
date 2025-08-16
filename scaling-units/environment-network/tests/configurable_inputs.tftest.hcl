run "test_configurable_vnet_large" {
  command = plan

  variables {
    location           = "West US 2"
    vnet_address_space = "172.16.0.0/12"
    core_subnet_prefix = "172.16.1.0/24"
    tags = {
      environment = "production"
      team        = "infrastructure"
    }
    suffix = "prod01"
  }
}

run "test_configurable_vnet_small" {
  command = plan

  variables {
    location           = "North Europe"
    vnet_address_space = "192.168.0.0/24"
    core_subnet_prefix = "192.168.0.0/28"
    tags = {
      environment = "development"
    }
    suffix = "dev01"
  }
}

run "test_configurable_different_regions" {
  command = plan

  variables {
    location           = "Australia East"
    vnet_address_space = "10.100.0.0/16"
    core_subnet_prefix = "10.100.50.0/24"
    tags = {
      environment = "staging"
      region      = "apac"
    }
    suffix = "stage01"
  }
}
