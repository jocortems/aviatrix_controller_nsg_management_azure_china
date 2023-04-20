resource "azurerm_public_ip" "transit_gateway_vip" {
  provider            = azurerm.aviatrix-gateways
  name                = format("%s-vip", var.gateway_name)
  resource_group_name = var.resource_group_name
  location            = var.region
  allocation_method   = "Static"  
  sku                 = "Standard"

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    {
    avx-gw-association = format("%s-gw", var.gateway_name)
    avx-created-resource = "DO-NOT-DELETE"
  },
  var.tags
  )
}

resource "azurerm_public_ip" "transit_gateway_ha_vip" {  
  count               = var.ha_enabled ? 1 : 0
  provider            = azurerm.aviatrix-gateways
  name                = format("%s-hagw-vip", var.gateway_name)
  resource_group_name = var.resource_group_name
  location            = var.region
  allocation_method   = "Static"
  sku                 = "Standard"

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    {
    avx-gw-association = format("%s-hagw", var.gateway_name)
    avx-created-resource = "DO-NOT-DELETE"
  },
  var.tags
  )
}

resource "azurerm_network_security_rule" "avx_controller_allow_gw" {
  provider                    = azurerm.aviatrix-controller
  name                        = format("%sgwInboundRule", var.gateway_name)
  resource_group_name         = var.aviatrix_controller_nsg_resource_group_name
  network_security_group_name = var.aviatrix_controller_nsg_name
  access                      = "Allow"
  direction                   = "Inbound"
  priority                    = var.aviatrix_controller_nsg_rule_priority
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefixes     = local.gateway_address
  destination_address_prefix  = "*"
  description                 = "Aviatrix GW name"
}