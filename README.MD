# Aviatrix Controller in Azure China NSG Management for Aviatrix Gateways Deployed in Azure China

## Description

### Note:

This Terraform module automates the creation of NSG rules in the NSG attached to an Aviatrix Controller deployed in Azure China to allow communication with Aviatrix Gateways. This is needed because Avitrix Controllers deployed in Azure China doesn't support Security Group Management; this makes deploying Aviatrix Gateways through automation using Terraform challenging, requiring users to manually add the public IP addresses of the gateways to the NSG attached to the controller before the gateway creation times out.

This Terraform module:

- Is limited to deployments in Azure China.
- Doesn't create any Aviatrix resources. It is intended to be used in conjunction with [mc-transit](https://registry.terraform.io/modules/terraform-aviatrix-modules/mc-transit/aviatrix/latest), [mc-spoke](https://registry.terraform.io/modules/terraform-aviatrix-modules/mc-spoke/aviatrix/latest) modules or Aviatrix Transit and Spoke gateway resources.
- Supports Azure controller deployment with only 6.7 and above versions.
- Creates one or two Standard Public IP addresses to be associated with the gateways.
- Adds a security rule to the existing NSG associated with an Azure Controller deployed in China


## Prerequisites

1. [Terraform v0.13+](https://www.terraform.io/downloads.html) - execute terraform files


## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 3.52 |


## Procedures for Building and Initializing a Controller in Azure

### 1. Authenticating to Azure

Set the environment in Azure CLI to Azure China:

```shell
az cloud set -n AzureChinaCloud
```

Login to the Azure CLI using:

```shell
az login --use-device-code
````
*Note: Please refer to the [documentation](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs#authenticating-to-azure-active-directory) for different methods of authentication to Azure, incase above command is not applicable.*

Pick the subscription you want and use it in the command below.

```shell
az account set --subscription <subscription_id>
```

Set environment variables ARM_ENDPOINT and ARM_ENVIRONMENT to use Azure China endpoints:

  ``` shell
  export ARM_ENDPOINT=https://management.chinacloudapi.cn
  export ARM_ENVIRONMENT=china
  ```

If executing this code from a CI/CD pipeline, the following environment variables are required. The service principal used to authenticate the CI/CD tool into Azure must either have subscription owner role or a custom role that has `Microsoft.Authorization/roleAssignments/write` to be able to succesfully create the role assignments required

``` shell
export ARM_CLIENT_ID="00000000-0000-0000-0000-000000000000"
export ARM_CLIENT_SECRET="00000000-0000-0000-0000-000000000000"
export ARM_SUBSCRIPTION_ID="00000000-0000-0000-0000-000000000000"
export ARM_TENANT_ID="00000000-0000-0000-0000-000000000000"
```

### 3. Applying Terraform configuration

```hcl

resource "azurerm_resource_group" "avx_transit_rg" {
  name     = "avx-transit-rg"
  location = "China North 3"
}

module "azure-gateway-nsg" {
  source                                      = "github.com/jocortems/aviatrix_controller_nsg_management_azure_china"
  resource_group_name                         = azurerm_resource_group.avx_transit_rg.name                      # Required. The name of the resource group where the Aviatrix Gateways will be deployed
  gateway_name                                = "example-gw"                                                    # Required. This is used to derive the name for the Public IP addresses that will be used by the Aviatrix Gateway
  region                                      = "China North 3"                                                 # Required. Azure China Region where the Aviatrix Gateways will be deployed
  tags                = {                                                                                       # Optional. These tags are only for the public IP addresses that will be created. In addition to the specified tags here the following tags are added {avx-gw-association = format("%s-gw", var.gateway_name), avx-created-resource = "DO-NOT-DELETE"} 
                          user = "jorge",
                          environment = "testing"
                        }
  ha_enabled                                  = true/false                                                      # Optional. Defaults to true. If set to false only one Public IP address is created and must disable ha_gw when creating Aviatrix spoke or transit gateways              
  aviatrix_controller_nsg_name                = "controller-nsg"                                                # Required. Name of the NSG associated with the Aviatrix Controller
  aviatrix_controller_nsg_resource_group_name = "controller-nsg-rg"                                             # Required. Name of the resource group where the NSG associated with the Aviatrix Controller is deployed
  aviatrix_controller_nsg_rule_priority       = 300                                                             # Required. This number must be unique. Before running this module verify the priority number is available in the NSG associated with the Aviatrix Controller
  aviatrix_gateway_subscription_name          = "Gateway Subscription"                                          # Optional. If this is not specified it defaults to the current subscription of the logged in user
  aviatrix_controller_subscription_name       = "Controller Subscription"                                       # Optional. If this is not specified it defaults to the value of aviatrix_gateway_subscription_name
}


module "mc-transit" {
  source                                      = "terraform-aviatrix-modules/mc-transit/aviatrix"
  version                                     = "2.3.2"
  name                                        = "avx-transit-vnet"
  account                                     = "azure-account"
  cloud                                       = "Azure"
  region                                      = "China North 3"
  az_support                                  = false
  gw_name                                     = "example-gw"
  resource_group                              = azurerm_resource_group.avx_transit_rg.name
  cidr                                        = "172.16.0.0/23"
  allocate_new_eip                            = false
  ha_azure_eip_name_resource_group            = "${module.azure-gateway-nsg.azure_gateway_ha_vip_name}:${azurerm_resource_group.avx_transit_rg.name}"
  azure_eip_name_resource_group               = "${module.azure-gateway-nsg.azure_gateway_vip_name}:${azurerm_resource_group.avx_transit_rg.name}"
  eip                                         = module.azure-gateway-nsg.azure_gateway_vip_address
  ha_eip                                      = module.azure-gateway-nsg.azure_gateway_ha_vip_address
}
```

### Execute

```shell
terraform init
terraform apply --var-file=<terraform.tfvars>
````

## **Disclaimer**:

The material embodied in this software/code is provided to you "as-is" and without warranty of any kind, express, implied or otherwise, including without limitation, any warranty of fitness for a particular purpose. In no event shall the Aviatrix Inc. be liable to you or anyone else for any direct, special, incidental, indirect or consequential damages of any kind, or any damages whatsoever, including without limitation, loss of profit, loss of use, savings or revenue, or the claims of third parties, whether or not Aviatrix Inc. has been advised of the possibility of such loss, however caused and on any theory of liability, arising out of or in connection with the possession, use or performance of this software/code.