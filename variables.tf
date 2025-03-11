variable "rg_name" {
    description = "The name of the resource group"
    type        = string
    default     = "rg1"
}

variable "subscription_id" {
    description = "The subscription id"
    type        = string
    default     = "417b4d8b-8673-4b95-9e59-429818b22af1"
  
}

variable "location" {
    description = "The location of the resource group"
    type        = string
    default     = "westeurope"
  
}

variable "authAppId" {
    description = "The auth app id"
    type        = string
    default     = "f37be710-de99-4d1d-bc62-8f5cde53d030"
  
}

variable "adme_name" {
    description = "The name of the adme instance"
    type        = string
    default     = "adme-dev"
  
}