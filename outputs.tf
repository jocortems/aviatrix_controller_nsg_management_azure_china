output "azure_gateway_vip_address" {
    value = azurerm_public_ip.transit_gateway_vip.ip_address
}

output "azure_gateway_ha_vip_address" {
    value = var.ha_enabled ? azurerm_public_ip.transit_gateway_ha_vip[0].ip_address : null
}

output "azure_gateway_vip_name" {
    value = azurerm_public_ip.transit_gateway_vip.name
}

output "azure_gateway_ha_vip_name" {
    value = var.ha_enabled ? azurerm_public_ip.transit_gateway_ha_vip[0].name : null
}