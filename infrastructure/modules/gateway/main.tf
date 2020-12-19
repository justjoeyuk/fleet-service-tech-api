resource "aws_api_gateway_resource" "default" {
  rest_api_id = var.rest_api_id
  parent_id   = var.parent_resource_id
  path_part   = var.path
}

resource "aws_api_gateway_method" "default" {
  rest_api_id   = var.rest_api_id
  resource_id   = aws_api_gateway_resource.default.id
  http_method   = var.http_method
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "default" {
  rest_api_id = var.rest_api_id
  resource_id = aws_api_gateway_resource.default.id
  http_method = aws_api_gateway_method.default.http_method

  integration_http_method = var.http_method
  type                    = "AWS_PROXY"
  uri                     = var.invoke_arn
}
