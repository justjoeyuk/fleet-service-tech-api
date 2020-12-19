output "resource_id" {
  value = aws_api_gateway_resource.default.id
}

output "integration" {
  value = aws_api_gateway_integration.default
}
