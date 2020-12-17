resource "aws_api_gateway_rest_api" "scanner_api" {
  name = "api-gateway"
  description = "Proxy to handle API Requests"
}

resource "aws_api_gateway_resource" "scanner_resource" {
  rest_api_id = aws_api_gateway_rest_api.scanner_api.id
  parent_id   = aws_api_gateway_rest_api.scanner_api.root_resource_id
  path_part   = "scan"
}

resource "aws_api_gateway_deployment" "scanner_deployment" {
   depends_on = [
     aws_api_gateway_integration.track_scan,
   ]

   rest_api_id = aws_api_gateway_rest_api.scanner_api.id
   stage_name  = "production"
}

output "base_url" {
  value = aws_api_gateway_deployment.scanner_deployment.invoke_url
}
