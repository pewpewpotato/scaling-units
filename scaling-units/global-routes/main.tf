# Use azure/naming module for consistent naming conventions
module "naming" {
  source  = "azure/naming/azurerm"
  version = "~> 0.4"
  suffix  = [var.suffix]
}

# Local values for consistent naming and configuration
locals {
  # Naming conventions
  endpoint_name     = "${module.naming.frontdoor.name}-endpoint"
  origin_group_name = "${module.naming.frontdoor.name}-origin-group"
  origin_name       = "${module.naming.frontdoor.name}-origin"
  custom_domain_name = replace(var.custom_domain, ".", "-")

  # Load balancing configuration
  load_balancing_sample_size                = 4
  load_balancing_successful_samples_required = 3

  # Origin configuration
  origin_weight   = 1000
  origin_priority = 1
}

# Create resource group for Front Door resources
resource "azurerm_resource_group" "this" {
  name     = module.naming.resource_group.name
  location = var.location
  tags     = var.tags
}

# Create Front Door profile with Standard SKU for optimal performance
resource "azurerm_cdn_frontdoor_profile" "this" {
  name                = module.naming.frontdoor.name
  resource_group_name = azurerm_resource_group.this.name
  sku_name            = "Standard_AzureFrontDoor"
  tags                = var.tags
}

# Create Front Door endpoint for traffic ingress
resource "azurerm_cdn_frontdoor_endpoint" "this" {
  name                     = local.endpoint_name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.this.id
  tags                     = var.tags
}

# Create Front Door origin group with load balancing (no health checks per requirements)
resource "azurerm_cdn_frontdoor_origin_group" "this" {
  name                     = local.origin_group_name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.this.id

  load_balancing {
    sample_size                 = local.load_balancing_sample_size
    successful_samples_required = local.load_balancing_successful_samples_required
  }

  # Note: Health probe intentionally omitted per PRD requirement
  # "No health check is required for the origin"
}

# Create Front Door origin pointing to Azure API Management
resource "azurerm_cdn_frontdoor_origin" "this" {
  name                          = local.origin_name
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.this.id

  enabled = true

  # Security: Enable certificate name check for HTTPS origins
  certificate_name_check_enabled = true

  # Origin configuration pointing to APIM FQDN
  host_name          = var.apim_fqdn
  http_port          = 80
  https_port         = 443
  origin_host_header = var.apim_fqdn
  priority           = local.origin_priority
  weight             = local.origin_weight
}

# Create custom domain with managed certificate and secure TLS configuration
resource "azurerm_cdn_frontdoor_custom_domain" "this" {
  name                     = local.custom_domain_name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.this.id
  host_name                = var.custom_domain

  tls {
    certificate_type    = "ManagedCertificate"
    minimum_tls_version = "TLS12"
  }
}

# Create Front Door route linking endpoint, origin, and custom domain
resource "azurerm_cdn_frontdoor_route" "this" {
  name                          = var.route_name
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.this.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.this.id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.this.id]
  cdn_frontdoor_custom_domain_ids = [azurerm_cdn_frontdoor_custom_domain.this.id]

  enabled = true

  # Security: Enforce HTTPS-only traffic
  forwarding_protocol    = "HttpsOnly"
  https_redirect_enabled = true
  patterns_to_match      = ["/*"]
  supported_protocols    = ["Http", "Https"]

  # Caching configuration for optimal performance
  cache {
    query_string_caching_behavior = "IgnoreQueryString"
  }
}
