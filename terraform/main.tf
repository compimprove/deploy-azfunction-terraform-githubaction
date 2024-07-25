terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.112.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "tfstate-github"
    storage_account_name = "tfstategithubaccount"
    container_name       = "tfstatecontainer"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_resource_group" "simpleapp_resource_group" {
  name = "simpleapp-resource-group"
}

resource "azurerm_storage_account" "simpleapp_storage" {
  name                     = "simpleappstorageaccount"
  resource_group_name      = data.azurerm_resource_group.simpleapp_resource_group.name
  location                 = data.azurerm_resource_group.simpleapp_resource_group.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "simpleapp_service_plan" {
  name                = "simpleapp-app-service-plan"
  location            = data.azurerm_resource_group.simpleapp_resource_group.location
  resource_group_name = data.azurerm_resource_group.simpleapp_resource_group.name
  sku_name            = "Y1"
  os_type             = "Linux"
}



resource "azurerm_linux_function_app" "simpleapp_app" {
  name                        = "simpleapp-app"
  location                    = data.azurerm_resource_group.simpleapp_resource_group.location
  resource_group_name         = data.azurerm_resource_group.simpleapp_resource_group.name
  service_plan_id             = azurerm_service_plan.simpleapp_service_plan.id
  storage_account_name        = azurerm_storage_account.simpleapp_storage.name
  storage_account_access_key  = azurerm_storage_account.simpleapp_storage.primary_access_key
  functions_extension_version = "~4"
  https_only                  = true

  identity {
    type = "SystemAssigned"
  }
  site_config {
    application_stack {
      node_version = 20
    }
  }
  lifecycle { ignore_changes = [app_settings["WEBSITE_RUN_FROM_PACKAGE"], app_settings["WEBSITE_ENABLE_SYNC_UPDATE_SITE"]] }
}

output "simpleapp_app_url" {
  value = azurerm_linux_function_app.simpleapp_app.default_hostname
}
