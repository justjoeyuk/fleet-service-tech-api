variable "rest_api_id" {
  type = string
  description = "The ID of the Gateway API to create resources upon"
}

variable "parent_resource_id" {
  type = string
  description = "The parent resource ID of the Gateway Resource"
}

variable "path" {
  type = string
  description = "The path for the output URL"
}

variable "invoke_arn" {
  type        = string
  description = "The ARN to Invoke for the gateway integration"
}

variable "http_method" {
  type        = string
  description = "The HTTP Method for the gateway integration and method"
  default     = "POST"
}
