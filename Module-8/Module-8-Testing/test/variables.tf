variable "port" {
  type    = number
  default = 443

  validation {
    condition     = var.port == 80 || var.port == 443
    error_message = "The port must be either 80 (HTTP) or 443 (HTTPS)."
  }
}

variable "storage_account_name" {
  type = string
}

variable "environment" {
  type = string
}