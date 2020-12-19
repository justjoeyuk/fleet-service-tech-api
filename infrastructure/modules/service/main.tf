// ZIP and Upload to S3
module "s3_package" {
  name = var.name
  source = "../package"
  zip_dir = "../build"
  zip_output_path = "../.."
  bucket_id = var.bucket_id
}

// Create Lambda Function
resource "aws_lambda_function" "default" {
  function_name = var.name
  s3_bucket     = var.bucket
  s3_key        = module.s3_package.key
  role          = var.lambda_role_arn
  source_code_hash = base64sha256(module.s3_package.output_path)
  handler       = "${var.name}.${var.handler}"
  runtime       = "nodejs12.x"

  vpc_config {
      subnet_ids = var.subnet_ids
      security_group_ids = var.security_group_ids
  }
  
  environment {
    variables = {
      rds_endpoint = var.db_endpoint
    }
  }

  depends_on = [
    # aws_iam_role_policy_attachment.lambda_logs,
    aws_cloudwatch_log_group.default,
  ]
}


// Create Log Group and Policy

resource "aws_cloudwatch_log_group" "default" {
  name              = "/aws/lambda/${var.name}"
  retention_in_days = 14
}


// Create the Gateway Resource

module "lambda_gateway" {
  source = "../gateway"
  rest_api_id = var.rest_api_id
  parent_resource_id = var.parent_resource_id
  path = var.name
  invoke_arn = aws_lambda_function.default.invoke_arn
}

// Apply Permissions

resource "aws_lambda_permission" "apigw" {
   statement_id  = "AllowAPIGatewayInvoke"
   action        = "lambda:InvokeFunction"
   function_name = aws_lambda_function.default.function_name
   principal     = "apigateway.amazonaws.com"
   source_arn = "${var.api_execution_arn}/*/*"
}
