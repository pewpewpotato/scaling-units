# ================================================================
# Front Door Profile Outputs
# ================================================================

output "front_door_profile_id" {
  description = "The ID of the Front Door profile"
  value       = azurerm_cdn_frontdoor_profile.this.id
}

output "front_door_profile_name" {
  description = "The name of the Front Door profile"
  value       = azurerm_cdn_frontdoor_profile.this.name
}

# ================================================================
# Front Door Endpoint Outputs
# ================================================================

output "front_door_endpoint_id" {
  description = "The ID of the Front Door endpoint"
  value       = azurerm_cdn_frontdoor_endpoint.this.id
}

output "front_door_endpoint_name" {
  description = "The name of the Front Door endpoint"
  value       = azurerm_cdn_frontdoor_endpoint.this.name
}

output "front_door_endpoint_hostname" {
  description = "The hostname of the Front Door endpoint"
  value       = azurerm_cdn_frontdoor_endpoint.this.host_name
}

# ================================================================
# Front Door Route and Origin Outputs
# ================================================================

output "front_door_route_id" {
  description = "The ID of the Front Door route"
  value       = azurerm_cdn_frontdoor_route.this.id
}

output "front_door_origin_group_id" {
  description = "The ID of the Front Door origin group"
  value       = azurerm_cdn_frontdoor_origin_group.this.id
}

output "front_door_origin_id" {
  description = "The ID of the Front Door origin"
  value       = azurerm_cdn_frontdoor_origin.this.id
}

output "front_door_custom_domain_id" {
  description = "The ID of the Front Door custom domain"
  value       = azurerm_cdn_frontdoor_custom_domain.this.id
}

# ================================================================
# Resource Group Outputs
# ================================================================

output "resource_group_id" {
  description = "The ID of the resource group containing the Front Door resources"
  value       = azurerm_resource_group.this.id
}

output "resource_group_name" {
  description = "The name of the resource group containing the Front Door resources"
  value       = azurerm_resource_group.this.name
}

# ================================================================
# Configuration Reference Outputs
# ================================================================

output "custom_domain_fqdn" {
  description = "The FQDN of the custom domain"
  value       = var.custom_domain
}

output "apim_fqdn" {
  description = "The FQDN of the APIM instance (origin target)"
  value       = var.apim_fqdn
}

output "route_name" {
  description = "The name of the created route"
  value       = var.route_name
}
