# Test for comprehensive module outputs

provider "azurerm" {
  features {}
  skip_provider_registration = true

  # Use dummy values to avoid authentication issues in testing
  subscription_id = "00000000-0000-0000-0000-000000000000"
  tenant_id       = "00000000-0000-0000-0000-000000000000"
  client_id       = "00000000-0000-0000-0000-000000000000"
  client_secret   = "dummy"
}

run "test_all_required_outputs" {
  command = plan

  variables {
    apim_fqdn     = "api.contoso.com"
    custom_domain = "contoso.com"
    route_name    = "api-route"
    location      = "East US"
    tags          = { Environment = "test", Project = "global-routes" }
    suffix        = "test01"
  }

  # Test that all critical resource IDs are exposed for downstream consumption
  assert {
    condition     = output.front_door_profile_id != null && output.front_door_profile_id != ""
    error_message = "front_door_profile_id output should be present and non-empty"
  }

  assert {
    condition     = output.front_door_profile_name != null && output.front_door_profile_name != ""
    error_message = "front_door_profile_name output should be present and non-empty"
  }

  assert {
    condition     = output.front_door_endpoint_id != null && output.front_door_endpoint_id != ""
    error_message = "front_door_endpoint_id output should be present and non-empty"
  }

  assert {
    condition     = output.front_door_endpoint_hostname != null && output.front_door_endpoint_hostname != ""
    error_message = "front_door_endpoint_hostname output should be present and non-empty"
  }

  assert {
    condition     = output.front_door_route_id != null && output.front_door_route_id != ""
    error_message = "front_door_route_id output should be present and non-empty"
  }

  assert {
    condition     = output.front_door_origin_group_id != null && output.front_door_origin_group_id != ""
    error_message = "front_door_origin_group_id output should be present and non-empty"
  }

  assert {
    condition     = output.front_door_origin_id != null && output.front_door_origin_id != ""
    error_message = "front_door_origin_id output should be present and non-empty"
  }

  assert {
    condition     = output.front_door_custom_domain_id != null && output.front_door_custom_domain_id != ""
    error_message = "front_door_custom_domain_id output should be present and non-empty"
  }

  assert {
    condition     = output.resource_group_id != null && output.resource_group_id != ""
    error_message = "resource_group_id output should be present and non-empty"
  }

  assert {
    condition     = output.resource_group_name != null && output.resource_group_name != ""
    error_message = "resource_group_name output should be present and non-empty"
  }

  # Test that configuration values are exposed
  assert {
    condition     = output.custom_domain_fqdn == var.custom_domain
    error_message = "custom_domain_fqdn output should match the input custom domain"
  }

  assert {
    condition     = output.apim_fqdn == var.apim_fqdn
    error_message = "apim_fqdn output should match the input APIM FQDN"
  }

  assert {
    condition     = output.route_name == var.route_name
    error_message = "route_name output should match the input route name"
  }
}

run "test_outputs_for_different_inputs" {
  command = plan

  variables {
    apim_fqdn     = "backend.example.org"
    custom_domain = "www.example.org"
    route_name    = "main-api"
    location      = "West US 2"
    tags          = { Environment = "production", Team = "platform" }
    suffix        = "prod"
  }

  # Test outputs reflect the different input values
  assert {
    condition     = output.custom_domain_fqdn == "www.example.org"
    error_message = "custom_domain_fqdn should reflect the input value"
  }

  assert {
    condition     = output.apim_fqdn == "backend.example.org"
    error_message = "apim_fqdn should reflect the input value"
  }

  assert {
    condition     = output.route_name == "main-api"
    error_message = "route_name should reflect the input value"
  }

  # Test that all resource IDs are still present with different inputs
  assert {
    condition     = length([for id in [
      output.front_door_profile_id,
      output.front_door_endpoint_id,
      output.front_door_route_id,
      output.front_door_origin_group_id,
      output.front_door_origin_id,
      output.front_door_custom_domain_id,
      output.resource_group_id
    ] : id if id != null && id != ""]) == 7
    error_message = "All seven resource ID outputs should be present and non-empty"
  }
}
