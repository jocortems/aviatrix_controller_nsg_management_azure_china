output "gateway_vip" {
    value = azurerm_public_ip.transit_gateway_vip
}

output "gateway_ha_vip" {
    value = var.ha_enabled ? azurerm_public_ip.transit_gateway_ha_vip[0] : null
}

output "gateway_resource_group" {
    value = var.use_existing_resource_group ? var.gateway_resource_group : azurerm_resource_group.gateway_resource_group[0].name
}