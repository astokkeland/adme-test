terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.22.0"
    }
  }
}
provider "azurerm" {
    features {}
  # Configuration options
}
 