run "test_module_outputs" {
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

  assert {
    condition     = output.virtual_network_name != ""
    error_message = "Module should output the virtual network name"
  }

  assert {
    condition     = output.virtual_network_id != ""
    error_message = "Module should output the virtual network resource ID"
  }

  assert {
    condition     = output.subnet_name != ""
    error_message = "Module should output the subnet name"
  }
}
