# Use azure/naming module for consistent naming conventions
module "naming" {
  source  = "azure/naming/azurerm"
  version = "~> 0.4"
  suffix  = [var.suffix]
}

# Create the resource group for APIM resources
resource "azurerm_resource_group" "this" {
  name     = module.naming.resource_group.name
  location = var.location
  tags     = var.tags
}

# Data source to get the existing virtual network
data "azurerm_virtual_network" "existing" {
  name                = var.vnet_name
  resource_group_name = var.vnet_resource_group_name
}

# Data source to get the existing NSG
data "azurerm_network_security_group" "existing" {
  name                = var.nsg_name
  resource_group_name = var.nsg_resource_group_name
}

# Create the subnet for APIM
resource "azurerm_subnet" "apim" {
  name                 = module.naming.subnet.name
  resource_group_name  = data.azurerm_virtual_network.existing.resource_group_name
  virtual_network_name = data.azurerm_virtual_network.existing.name
  address_prefixes     = [var.apim_subnet_prefix]

  # Enable service endpoints required for APIM
  service_endpoints = [
    "Microsoft.Storage",
    "Microsoft.KeyVault",
    "Microsoft.Sql",
    "Microsoft.EventHub",
    "Microsoft.ServiceBus"
  ]
}

# NSG Rules for APIM - Inbound
resource "azurerm_network_security_rule" "apim_inbound" {
  for_each = {
    "AllowAPIMManagement" = {
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "3443"
      source_address_prefix      = "ApiManagement"
      destination_address_prefix = "VirtualNetwork"
      description                = "Allow APIM management endpoint access"
    }
    "AllowLoadBalancer" = {
      priority                   = 110
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "6390"
      source_address_prefix      = "AzureLoadBalancer"
      destination_address_prefix = "VirtualNetwork"
      description                = "Allow Azure Load Balancer health probes"
    }
    "AllowHTTPS" = {
      priority                   = 120
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "Internet"
      destination_address_prefix = "VirtualNetwork"
      description                = "Allow HTTPS traffic from Internet"
    }
    "AllowHTTP" = {
      priority                   = 130
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "80"
      source_address_prefix      = "Internet"
      destination_address_prefix = "VirtualNetwork"
      description                = "Allow HTTP traffic from Internet"
    }
  }

  name                        = each.key
  resource_group_name         = data.azurerm_network_security_group.existing.resource_group_name
  network_security_group_name = data.azurerm_network_security_group.existing.name
  priority                    = each.value.priority
  direction                   = each.value.direction
  access                      = each.value.access
  protocol                    = each.value.protocol
  source_port_range           = each.value.source_port_range
  destination_port_range      = each.value.destination_port_range
  source_address_prefix       = each.value.source_address_prefix
  destination_address_prefix  = each.value.destination_address_prefix
  description                 = each.value.description
}

# NSG Rules for APIM - Outbound
resource "azurerm_network_security_rule" "apim_outbound" {
  for_each = {
    "AllowHTTPSOutbound" = {
      priority                   = 100
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "*"
      description                = "Allow HTTPS outbound traffic"
    }
    "AllowStorageOutbound" = {
      priority                   = 110
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "Storage"
      description                = "Allow access to Azure Storage"
    }
    "AllowSQLOutbound" = {
      priority                   = 120
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "1433"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "Sql"
      description                = "Allow access to Azure SQL Database"
    }
    "AllowEventHubOutbound" = {
      priority                   = 130
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "5671-5672"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "EventHub"
      description                = "Allow access to Azure Event Hub"
    }
    "AllowSMTPOutbound" = {
      priority                   = 140
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "25,587,25028"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "*"
      description                = "Allow SMTP for email notifications"
    }
  }

  name                        = each.key
  resource_group_name         = data.azurerm_network_security_group.existing.resource_group_name
  network_security_group_name = data.azurerm_network_security_group.existing.name
  priority                    = each.value.priority
  direction                   = each.value.direction
  access                      = each.value.access
  protocol                    = each.value.protocol
  source_port_range           = each.value.source_port_range
  destination_port_range      = each.value.destination_port_range
  source_address_prefix       = each.value.source_address_prefix
  destination_address_prefix  = each.value.destination_address_prefix
  description                 = each.value.description
}

# Associate NSG with the APIM subnet
resource "azurerm_subnet_network_security_group_association" "apim" {
  subnet_id                 = azurerm_subnet.apim.id
  network_security_group_id = data.azurerm_network_security_group.existing.id
}

# Create the API Management instance
resource "azurerm_api_management" "this" {
  name                = module.naming.api_management.name
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  publisher_name      = "Default Publisher"
  publisher_email     = "admin@example.com"
  sku_name            = "Developer_1"
  tags                = var.tags

  # Configure virtual network integration
  virtual_network_configuration {
    subnet_id = azurerm_subnet.apim.id
  }

  depends_on = [
    azurerm_network_security_rule.apim_inbound,
    azurerm_network_security_rule.apim_outbound,
    azurerm_subnet_network_security_group_association.apim
  ]
}
