resource "aws_api_gateway_resource" "track_scan_resource" {
  rest_api_id = aws_api_gateway_rest_api.scanner_api.id
  parent_id   = aws_api_gateway_resource.scanner_resource.id
  path_part   = "track-scan"
}

resource "aws_api_gateway_method" "track_scan" {
  rest_api_id   = aws_api_gateway_rest_api.scanner_api.id
  resource_id   = aws_api_gateway_resource.track_scan_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_lambda_function" "track_scan" {
  function_name = "track-scan"
  s3_bucket     = aws_s3_bucket.lambda_bucket.bucket
  s3_key        = aws_s3_bucket_object.lambda_upload.key
  role          = aws_iam_role.lambda_role.arn
  source_code_hash = base64sha256(data.archive_file.lambda_source.output_path)
  handler       = "track-scan.handler"
  runtime       = "nodejs12.x"

  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs,
    aws_cloudwatch_log_group.track_scan,
  ]
}

resource "aws_lambda_permission" "apigw" {
   statement_id  = "AllowAPIGatewayInvoke"
   action        = "lambda:InvokeFunction"
   function_name = aws_lambda_function.track_scan.function_name
   principal     = "apigateway.amazonaws.com"
   source_arn = "${aws_api_gateway_rest_api.scanner_api.execution_arn}/*/*"
}

resource "aws_api_gateway_integration" "track_scan" {
  rest_api_id = aws_api_gateway_rest_api.scanner_api.id
  resource_id = aws_api_gateway_resource.track_scan_resource.id
  http_method = aws_api_gateway_method.track_scan.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.track_scan.invoke_arn
}

resource "aws_cloudwatch_log_group" "track_scan" {
  name              = "/aws/lambda/track-scan"
  retention_in_days = 14
}

resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = file("IAM/lambda_cloudwatch_policy.json")
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}
