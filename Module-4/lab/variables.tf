variable "location" {
  type    = string
  default = "westeurope"
}
variable "environment" {
  type    = string
}
variable "storage_account_name" {
  type = string
}
variable "sa_name_suffix" {
  type    = list(string)
}
variable "admin_password" {
  type = string
  default = null
}