# Global Routes Stamp Module

This module provides a reusable OpenTofu/Terraform module for defining Azure Front Door routes, origin groups, and origins that point to Azure API Management (APIM). It enables scalable, consistent, and reusable routing patterns for cloud infrastructure projects, supporting custom DNS association and modular integration.

## Features

- ✅ Creates Azure Front Door profile with Standard SKU
- ✅ Configures Front Door endpoint for traffic ingress
- ✅ Sets up origin group with load balancing (no health checks as per requirements)
- ✅ Creates origin pointing to Azure API Management FQDN
- ✅ Associates custom domain with managed certificates
- ✅ Configures HTTPS-only routing with automatic redirects
- ✅ Uses azure/naming module for consistent resource naming
- ✅ Comprehensive input validation and error handling

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| azurerm | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | ~> 3.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| naming | azure/naming/azurerm | ~> 0.4 |

## Resources

| Name | Type |
|------|------|
| azurerm_resource_group.this | resource |
| azurerm_cdn_frontdoor_profile.this | resource |
| azurerm_cdn_frontdoor_endpoint.this | resource |
| azurerm_cdn_frontdoor_origin_group.this | resource |
| azurerm_cdn_frontdoor_origin.this | resource |
| azurerm_cdn_frontdoor_custom_domain.this | resource |
| azurerm_cdn_frontdoor_route.this | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| apim_fqdn | The FQDN of the Azure API Management instance to route traffic to | `string` | n/a | yes |
| custom_domain | The custom domain to associate with the Front Door route | `string` | n/a | yes |
| route_name | The name of the Front Door route | `string` | n/a | yes |
| location | The Azure region where resources will be created | `string` | n/a | yes |
| suffix | The suffix to append to resource names for uniqueness | `string` | n/a | yes |
| tags | A map of tags to assign to resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| front_door_profile_id | The ID of the Front Door profile |
| front_door_profile_name | The name of the Front Door profile |
| front_door_endpoint_id | The ID of the Front Door endpoint |
| front_door_endpoint_name | The name of the Front Door endpoint |
| front_door_endpoint_hostname | The hostname of the Front Door endpoint |
| front_door_route_id | The ID of the Front Door route |
| front_door_origin_group_id | The ID of the Front Door origin group |
| front_door_origin_id | The ID of the Front Door origin |
| front_door_custom_domain_id | The ID of the Front Door custom domain |
| resource_group_id | The ID of the resource group containing the Front Door resources |
| resource_group_name | The name of the resource group containing the Front Door resources |
| custom_domain_fqdn | The FQDN of the custom domain |
| apim_fqdn | The FQDN of the APIM instance (origin target) |
| route_name | The name of the created route |

## Example Usage

### Basic Usage

```hcl
module "global_routes" {
  source = "./modules/global-routes"

  apim_fqdn     = "api.contoso.com"
  custom_domain = "contoso.com"
  route_name    = "api-route"
  location      = "East US"
  suffix        = "prod01"
  
  tags = {
    Environment = "production"
    Project     = "api-gateway"
  }
}
```

### Advanced Usage with Multiple Routes

```hcl
module "api_routes" {
  source = "./modules/global-routes"

  apim_fqdn     = "api-backend.example.com"
  custom_domain = "api.example.com"
  route_name    = "main-api"
  location      = "West US 2"
  suffix        = "prod"
  
  tags = {
    Environment = "production"
    Team        = "platform"
    CostCenter  = "engineering"
  }
}

module "admin_routes" {
  source = "./modules/global-routes"

  apim_fqdn     = "api-backend.example.com"
  custom_domain = "admin.example.com"
  route_name    = "admin-api"
  location      = "West US 2"
  suffix        = "prod"
  
  tags = {
    Environment = "production"
    Team        = "platform"
    CostCenter  = "engineering"
  }
}
```

### Using Outputs in Downstream Modules

```hcl
module "global_routes" {
  source = "./modules/global-routes"

  apim_fqdn     = var.apim_fqdn
  custom_domain = var.custom_domain
  route_name    = var.route_name
  location      = var.location
  suffix        = var.suffix
  tags          = var.tags
}

# Use the Front Door endpoint in other configurations
resource "azurerm_dns_cname_record" "api" {
  name                = "api"
  zone_name           = azurerm_dns_zone.main.name
  resource_group_name = azurerm_dns_zone.main.resource_group_name
  ttl                 = 300
  target_resource_id  = module.global_routes.front_door_endpoint_id
}

# Reference in monitoring or alerting
resource "azurerm_monitor_metric_alert" "front_door_health" {
  name                = "front-door-health-alert"
  resource_group_name = module.global_routes.resource_group_name
  scopes              = [module.global_routes.front_door_profile_id]
  
  # ... alert configuration
}
```

## Input Validation

This module includes comprehensive input validation:

### APIM FQDN Validation
- Must be a valid domain name (1-253 characters)
- Must include a top-level domain (minimum 2 characters)
- Cannot start or end with a dot
- Example: `api.contoso.com` ✅, `invalid-fqdn` ❌

### Custom Domain Validation
- Must be a valid domain name (1-253 characters)
- Must include a top-level domain (minimum 2 characters) 
- Cannot start or end with a dot
- Example: `contoso.com` ✅, `invalid-domain` ❌

### Route Name Validation
- Must be 1-80 characters
- Can contain alphanumeric characters and hyphens
- Cannot start or end with a hyphen
- Example: `api-route` ✅, `-invalid-route` ❌

### Suffix Validation
- Must be 1-10 characters
- Can contain only alphanumeric characters
- Used by azure/naming module for resource uniqueness
- Example: `prod01` ✅, `test-suffix-too-long` ❌

## Architecture

This module creates the following Azure Front Door architecture:

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Custom Domain │    │   Front Door     │    │   APIM Instance │
│   (contoso.com) │───▶│     Profile      │───▶│ (api.contoso...)│
└─────────────────┘    │                  │    └─────────────────┘
                       │  ┌─────────────┐ │
                       │  │  Endpoint   │ │
                       │  └─────────────┘ │
                       │  ┌─────────────┐ │
                       │  │    Route    │ │
                       │  └─────────────┘ │
                       │  ┌─────────────┐ │
                       │  │Origin Group │ │
                       │  └─────────────┘ │
                       │  ┌─────────────┐ │
                       │  │   Origin    │ │
                       │  └─────────────┘ │
                       └──────────────────┘
```

### Key Configuration Details

- **SKU**: Standard_AzureFrontDoor for cost-effective routing
- **HTTPS**: Enforced with automatic HTTP-to-HTTPS redirects
- **Certificates**: Managed certificates with TLS 1.2 minimum
- **Health Checks**: Disabled as per requirements (no health probes)
- **Load Balancing**: Configured with sample size 4, success threshold 3
- **Caching**: Query string caching disabled by default

## Security Features

- **HTTPS Only**: All traffic enforced to use HTTPS
- **TLS 1.2+**: Minimum TLS version enforced
- **Managed Certificates**: Automatic certificate provisioning and renewal
- **Certificate Name Checking**: Enabled on origins for security
- **Input Validation**: Comprehensive validation prevents injection attacks

## Troubleshooting

### Common Issues

1. **Invalid FQDN Error**: Ensure APIM FQDN and custom domain are valid domain names with TLDs
2. **Naming Conflicts**: Use unique suffix values to avoid resource naming conflicts
3. **Certificate Issues**: Managed certificates require domain validation - ensure DNS is properly configured
4. **Route Name Errors**: Follow naming convention (alphanumeric + hyphens, no leading/trailing hyphens)

### Testing

Run the included tests to validate your configuration:

```bash
tofu test tests/input_validation.tftest.hcl
tofu test tests/front_door_resources.tftest.hcl
tofu test tests/custom_domain_association.tftest.hcl
tofu test tests/naming_conventions.tftest.hcl
tofu test tests/output_validation.tftest.hcl
```

## License

This module is part of the internal infrastructure codebase and follows the same licensing terms as the parent project.
