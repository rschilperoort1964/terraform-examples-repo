terraform {
  backend "azurerm" {
    resource_group_name   = "RS_resource_group"         # <-- Replace with your actual resource group
    storage_account_name  = "rschilpstoragelab5"
    container_name        = "rslab5"
    key                   = "terraform.tfstate"
    sas_token             = "sp=racwdl&st=2025-06-12T11:48:34Z&se=2025-06-12T19:48:34Z&spr=https&sv=2024-11-04&sr=c&sig=Ytacol06hpFeYA0uPf%2F635KMol1%2FBF7CQfyN9j3cbxM%3D"
  }
}