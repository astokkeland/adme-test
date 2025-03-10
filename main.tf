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
