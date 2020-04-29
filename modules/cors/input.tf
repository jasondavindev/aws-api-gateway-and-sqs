variable "api_id" {}

variable "api_resource_id" {}

variable "allow_max_age" {
  default = "7200"
}

variable "allow_credentials" {
  default = false
}

variable "allow_headers" {
  type = "list"
  default = [
    "Authorization",
    "Content-Type",
    "X-Amz-Date",
    "X-Amz-Security-Token",
    "X-Api-Key",
  ]
}

variable "allow_methods" {
  type = "list"
  default = [
    "GET",
    "POST",
    "PUT",
    "PATCH",
    "OPTIONS",
    "DELETE"
  ]
}

variable "allow_origins" {
  type = "list"
  default = [
    "*"
  ]
}
