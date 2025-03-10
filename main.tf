resource "azurerm_resource_group" "default" {
  name     = "rg1"
  location = "westeurope"
}

resource "azurerm_virtual_network" "default" {
  name                = "vnet1"
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "default" {
    name                 = "subnet1"
    resource_group_name  = azurerm_resource_group.default.name
    virtual_network_name = azurerm_virtual_network.default.name
    address_prefixes     = ["10.0.1.0/24"]
  
}

resource "azurerm_resource_group_template_deployment" "example" {
  name                = "test"
  resource_group_name = azurerm_resource_group.default.name
  deployment_mode     = "Incremental"
  parameters_content = jsonencode({
    "name" = {
      value = "test"}
    "location" = {
      value ="westeurope"}
    "tagsByResource" = {
      value = {}
    }
    "authAppId" = {
      value ="f37be710-de99-4d1d-bc62-8f5cde53d030"}
    "dataPartitionNames" = {
      value = [
        {
        "name"="dp1"}
      ]
    }
    "cmkEnabled" = {
      value =false}
    "encryption" =  {
      value ={}}
    "identity" = {
      value ={}}
    "corsRules" = {
      value =[]}
    "sku" = {
      value ={
      "name" = "Developer"
      "tier" = "Standard"
      }
    }
    "publicNetworkAccess" = {
      value =false}
    "privateEndpoints" = {
      value =[] }
    "resourceGroupId" ={
      value = "/subscriptions/417b4d8b-8673-4b95-9e59-429818b22af1/resourceGroups/rg1"}
  })

  template_content    = file("template.json")
  }