variable "gateway_resource_group" {
    type = string
    description = "Name of the resource group where Aviatrix Gateways, Azure Public IP addresses and Azure VNET will be deployed"
}

variable "use_existing_resource_group" {
    type = bool
    description = "Whether to deploy a resource group in the Azure Subscription where the gateways will be deployed or create a new resource group"
    default = false
}

variable "gateway_name" {
    type = string
    description = "Name of the Aviatrix Gateway"
}

variable "gateway_region" {
    type = string
    description = "Azure region where Aviatrix Gateways, Public IP addresses and VNET/VPC will be deployed"
}

variable "tags" {
    type = map
    description = "Tags to be applied to the public IP addresses created for the gateways. Make sure to use the correct format depending on the cloud you are deploying"
    default = {}
}

variable "controller_nsg_name" {
    type = string
    description = "Name of the Network Security Group attached to the Aviatrix Controller Network Interface"  
}

variable "controller_nsg_resource_group_name" {
    type = string
    description = "Name of the Resource Group where the Network Security Group attached to the Aviatrix Controller Network Interface is deployed"  
}

variable "controller_nsg_rule_priority" {
    type = number
    description = "Priority of the rule that will be created in the existing Network Security Group attached to the Aviatrix Controller Network Interface. This number must be unique. Valid values are 100-4096"
    
    validation {
      condition = var.controller_nsg_rule_priority >= 100 && var.controller_nsg_rule_priority <= 4096
      error_message = "Priority must be a number between 100 and 4096"
    }
}

variable "ha_enabled" {
    type = bool
    description = "Whether HAGW will be deployed. Defaults to true"
    default = true
}

variable "gateway_subscription_name" {
  type = string
  description = "Display Name of the Azure subscription where the Aviatrix Gateway public IP addresses will be created"
  default = ""
}

variable "controller_subscription_name" {
  type = string
  description = "Display Name of the Azure subscription where the Aviatrix Controller is created"
  default = ""
}

locals {
  gateway_subscription = [for subscription in data.azurerm_subscriptions.available.subscriptions : subscription if subscription.display_name == var.gateway_subscription_name][0]
  controller_subscription = length(var.controller_subscription_name) > 0 ? [for subscription in data.azurerm_subscriptions.available.subscriptions : subscription if subscription.display_name == var.controller_subscription_name][0] : local.gateway_subscription
  gateway_address = var.ha_enabled ? ["${azurerm_public_ip.transit_gateway_vip.ip_address}/32", "${azurerm_public_ip.transit_gateway_ha_vip[0].ip_address}/32"] : ["${azurerm_public_ip.transit_gateway_vip.ip_address}/32"]
}