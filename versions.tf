terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.52.0"
  }
}
}

provider azurerm {
    alias = "aviatrix-gateways"
    tenant_id = local.gateway_tenant_id
    subscription_id = local.gateway_subscription_id
    environment = "china"
    features {
      resource_group {
        prevent_deletion_if_contains_resources = true
    }
    }
}

provider azurerm {
    alias = "aviatrix-controller"
    tenant_id = local.controller_tenant_id
    subscription_id = local.controller_subscription_id
    environment = "china"
    features {}
}