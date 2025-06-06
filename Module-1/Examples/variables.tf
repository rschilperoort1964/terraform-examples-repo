variable "project" {
  description = "The name of the project"
  type        = string
}

variable "environment" {
  description = "The deployment environment (e.g., dev, test, prod)"
  type        = string
}

variable "location" {
  description = "Azure region to deploy to"
  type        = string
}


