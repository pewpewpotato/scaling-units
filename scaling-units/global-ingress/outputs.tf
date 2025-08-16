output "resource_group_name" {
  description = "The name of the created resource group"
  value       = azurerm_resource_group.main.name
}

output "cdn_profile_name" {
  description = "The name of the created CDN profile"
  value       = azurerm_cdn_frontdoor_profile.main.name
}

output "resource_name" {
  description = "The primary resource name (CDN profile name)"
  value       = azurerm_cdn_frontdoor_profile.main.name
}
