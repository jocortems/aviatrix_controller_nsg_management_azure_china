terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.52.0"
  }
  aws = {
      source = "hashicorp/aws"
      version = "~> 4.63.0"
    }
  alicloud = {
      source = "aliyun/alicloud"
      version = "~> 1.203.0"
    }
}
}

provider azurerm {
    alias = "aviatrix-gateways"
    tenant_id = var.aviatrix_gateway_azure_tenant_id
    subscription_id = var.aviatrix_gateway_azure_subscription_id
    environment = "china"
    features {}
}

provider azurerm {
    alias = "aviatrix-controller"
    tenant_id = local.azuread_controller_tenant_id
    subscription_id = local.azure_controller_subscription_id
    environment = "china"
    features {}
}

/*
provider "aws" {
    region = var.region  
}

provider "alicloud" {
    region = var.region  
}
*/