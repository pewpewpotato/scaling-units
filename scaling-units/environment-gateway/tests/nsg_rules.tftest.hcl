provider "azurerm" {
  features {}
  skip_provider_registration = true
}

run "test_nsg_rules_for_apim" {
  command = plan

  variables {
    vnet_name                = "test-vnet"
    vnet_resource_group_name = "test-vnet-rg"
    nsg_name                 = "test-nsg"
    nsg_resource_group_name  = "test-nsg-rg"
    apim_subnet_prefix       = "10.0.1.0/24"
    location                 = "eastus"
    tags = {
      environment = "test"
    }
    suffix = "test"
  }

  # Test that required NSG rules are created for APIM
  assert {
    condition     = length([for rule in azurerm_network_security_rule.apim_inbound : rule if rule.destination_port_range == "3443"]) > 0
    error_message = "NSG should have inbound rule for APIM management endpoint (port 3443)"
  }

  assert {
    condition     = length([for rule in azurerm_network_security_rule.apim_inbound : rule if rule.source_address_prefix == "ApiManagement"]) > 0
    error_message = "NSG should have rule allowing traffic from ApiManagement service tag"
  }

  assert {
    condition     = length([for rule in azurerm_network_security_rule.apim_outbound : rule if rule.destination_port_range == "443"]) > 0
    error_message = "NSG should have outbound rule for HTTPS traffic (port 443)"
  }
}
