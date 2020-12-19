variable "name" {
  type        = string
  description = "The name of the file for the service (i.e my-service)"
}

variable "handler" {
  type        = string
  description = "The name of the handler function inside the file for the function"
  default     = "handler"
}

variable "bucket_id" {
  type        = string
  description = "The bucket ID for the service"
}

variable "bucket" {
  type        = string
  description = "The bucket for the service"
}

variable "rest_api_id" {
  type        = string
  description = "The ID of the Gateway API to create resources upon"
}

variable "parent_resource_id" {
  type        = string
  description = "The parent resource ID of the Gateway Resource"
}

variable "api_execution_arn" {
  type        = string
  description = "The gateway execution arn"
}

variable "lambda_role_arn" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_ids" {
  type = list(string)
}

variable "db_endpoint" {
  type = string
}
