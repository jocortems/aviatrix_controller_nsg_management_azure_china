variable "resource_group_name" {
    type = string
    description = "Name of the resource group where Aviatrix Gateways, Azure Public IP addresses and Azure VNET will be deployed"
}

variable "gateway_name" {
    type = string
    description = "Name of the Aviatrix Gateway"
}

variable "region" {
    type = string
    description = "Azure region where Aviatrix Gateways, Public IP addresses and VNET/VPC will be deployed"
}

variable "tags" {
    type = map
    description = "Tags to be applied to the public IP addresses created for the gateways. Make sure to use the correct format depending on the cloud you are deploying"
    default = {}
}

variable "aviatrix_controller_nsg_name" {
    type = string
    description = "Name of the Network Security Group attached to the Aviatrix Controller Network Interface"  
}

variable "aviatrix_controller_nsg_resource_group_name" {
    type = string
    description = "Name of the Resource Group where the Network Security Group attached to the Aviatrix Controller Network Interface is deployed"  
}

variable "aviatrix_controller_nsg_rule_priority" {
    type = number
    description = "Priority of the rule that will be created in the existing Network Security Group attached to the Aviatrix Controller Network Interface. This number must be unique. Valid values are 100-4096"
    
    validation {
      condition = var.aviatrix_controller_nsg_rule_priority >= 100 && var.aviatrix_controller_nsg_rule_priority <= 4096
      error_message = "Priority must be a number between 100 and 4096"
    }
}

variable "ha_enabled" {
    type = bool
    description = "Whether HAGW will be deployed. Defaults to true"
    default = true
}

variable "aviatrix_gateway_azure_subscription_id" {
    type = string
    description = "Azure subscription GUID where Aviatrix Gateways will be deployed"
    default = ""

    validation {
      condition     = can(regex("^[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}$", var.aviatrix_gateway_azure_subscription_id))
      error_message = "The value must be a valid GUID in the format"  
    }
}

variable "aviatrix_controller_azure_subscription_id" {
    type = string
    description = "Azure subscription GUID where Aviatrix Controller is deployed. Defaults to the value of variable aviatrix_gateway_azure_subscription_id"
    default = ""

    validation {
      condition     = can(regex("^[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}$", var.aviatrix_controller_azure_subscription_id)) || length(var.aviatrix_controller_azure_subscription_id) == 0
      error_message = "The value must be a valid GUID in the format"  
    }
}

variable "aviatrix_gateway_azure_tenant_id" {
    type = string
    description = "Azure AD Tenant GUID where Aviatrix Gateways will be deployed"

    validation {
      condition     = can(regex("^[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}$", var.aviatrix_gateway_azure_tenant_id))
      error_message = "The value must be a valid GUID in the format"  
    }
}

variable "aviatrix_controller_azure_tenant_id" {
    type = string
    description = "Azure AD Tenant GUID where Aviatrix Controller is deployed. Defaults to the value of variable aviatrix_gateway_azure_tenant_id"
    default = ""

    validation {
      condition     = can(regex("^[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}$", var.aviatrix_controller_azure_tenant_id)) || length(var.aviatrix_controller_azure_tenant_id) == 0
      error_message = "The value must be a valid GUID in the format"  
    }
}

locals {
  azuread_controller_tenant_id = length(var.aviatrix_controller_azure_tenant_id) > 0 ? var.aviatrix_controller_azure_tenant_id : var.aviatrix_gateway_azure_tenant_id 
  azure_controller_subscription_id = length(var.aviatrix_controller_azure_subscription_id) > 0 ? var.aviatrix_controller_azure_subscription_id : var.aviatrix_gateway_azure_subscription_id
  gateway_address = var.ha_enabled ? ["${azurerm_public_ip.transit_gateway_vip.ip_address}/32", "${azurerm_public_ip.transit_gateway_ha_vip[0].ip_address}/32"] : ["${azurerm_public_ip.transit_gateway_vip.ip_address}/32"]
}