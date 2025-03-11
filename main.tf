resource "azurerm_resource_group" "default" {
  name     = "rg1"
  location = "westeurope"
}

resource "azurerm_virtual_network" "adme" {
  name                = "vnet_adme"
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "adme" {
    name                 = "subnet_adme"
    resource_group_name  = azurerm_resource_group.default.name
    virtual_network_name = azurerm_virtual_network.adme.name
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





resource "azurerm_virtual_network" "appgw" {
  name                = "vn_appgw"
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
  address_space       = ["10.2.0.0/16"]
}

resource "azurerm_subnet" "appgw" {
  name                 = "subnet_appgw"
  resource_group_name  = azurerm_resource_group.default.name
  virtual_network_name = azurerm_virtual_network.appgw.name
  address_prefixes     = ["10.2.0.0/24"]
}

resource "azurerm_public_ip" "example" {
  name                = "example-pip"
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
  allocation_method   = "Static"
}

# since these variables are re-used - a locals block makes this more maintainable
locals {
  backend_address_pool_name      = "${azurerm_virtual_network.appgw.name}-beap"
  frontend_port_name             = "${azurerm_virtual_network.appgw.name}-feport"
  frontend_ip_configuration_name = "${azurerm_virtual_network.appgw.name}-feip"
  http_setting_name              = "${azurerm_virtual_network.appgw.name}-be-htst"
  listener_name                  = "${azurerm_virtual_network.appgw.name}-httplstn"
  request_routing_rule_name      = "${azurerm_virtual_network.appgw.name}-rqrt"
  redirect_configuration_name    = "${azurerm_virtual_network.appgw.name}-rdrcfg"
}

resource "azurerm_application_gateway" "network" {
  name                = "example-appgw"
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 2
  }

  waf_configuration {
    enabled = true
    firewall_mode = "Prevention"
    rule_set_type = "OWASP"
    rule_set_version = "3.0"
  }
  
  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = azurerm_subnet.appgw.id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.example.id
  }

  backend_address_pool {
    name = local.backend_address_pool_name

  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    path                  = "/path1/"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    priority                   = 9
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }
}