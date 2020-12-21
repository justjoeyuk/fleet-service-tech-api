provider "aws" {
  region = "us-east-1"
}

// Create the environment

module "scannerfleet_vpc" {
  source = "./modules/vpc"
  region = "us-east-1"
}

// Create the Database

resource "aws_db_instance" "scannerfleet_db" {
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "postgres"
  instance_class         = "db.t2.micro"
  name                   = "ScannerFleetDB"
  username               = var.pg_username
  password               = var.pg_password
  apply_immediately      = true
  db_subnet_group_name   = module.scannerfleet_vpc.subnet_group_id
  vpc_security_group_ids = [module.scannerfleet_vpc.security_group_id]
  skip_final_snapshot    = true
  publicly_accessible    = true
}


// Create the S3 Bucket

module "lambda_s3_bucket" {
  source = "./modules/s3"
  name   = "fleet-service-functions-buckets-1"
}

// Setup the Roles and Policies

resource "aws_iam_role" "lambda_role" {
  name               = "lambda_role"
  assume_role_policy = file("modules/config/policies/lambda_assume_role_policy.json")
}

resource "aws_iam_role_policy" "lambda_policy" {
  name   = "lambda_policy"
  role   = aws_iam_role.lambda_role.id
  policy = file("modules/config/policies/lambda_policy.json")
}

resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = file("modules/config/policies/lambda_cloudwatch_policy.json")
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}

resource "aws_iam_role_policy_attachment" "lambda_vpc" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}


// Setup API

resource "aws_api_gateway_rest_api" "scanner_api" {
  name        = "api-gateway"
  description = "Proxy to handle API Requests"
}

resource "aws_api_gateway_resource" "scanner_resource" {
  rest_api_id = aws_api_gateway_rest_api.scanner_api.id
  parent_id   = aws_api_gateway_rest_api.scanner_api.root_resource_id
  path_part   = "scan"
}

resource "aws_api_gateway_deployment" "scanner_deployment" {
  depends_on = [
    module.track_scan_service.gateway_integration,
    module.get_scans_service.gateway_integration,
  ]

  rest_api_id = aws_api_gateway_rest_api.scanner_api.id
  stage_name  = "production"

  variables = {
    deployed_at = timestamp() # not good, redeploys every run regardless
  }
}


// Create Services

module "track_scan_service" {
  source             = "./modules/service"
  name               = "track-scan"
  bucket_id          = module.lambda_s3_bucket.id
  bucket             = module.lambda_s3_bucket.bucket
  rest_api_id        = aws_api_gateway_rest_api.scanner_api.id
  parent_resource_id = aws_api_gateway_resource.scanner_resource.id
  api_execution_arn  = aws_api_gateway_rest_api.scanner_api.execution_arn
  lambda_role_arn    = aws_iam_role.lambda_role.arn
  subnet_ids         = module.scannerfleet_vpc.subnet_ids
  security_group_ids = module.scannerfleet_vpc.security_group_ids
  db_endpoint        = aws_db_instance.scannerfleet_db.endpoint
}

module "get_scans_service" {
  source             = "./modules/service"
  name               = "get-scans"
  bucket_id          = module.lambda_s3_bucket.id
  bucket             = module.lambda_s3_bucket.bucket
  rest_api_id        = aws_api_gateway_rest_api.scanner_api.id
  parent_resource_id = aws_api_gateway_resource.scanner_resource.id
  api_execution_arn  = aws_api_gateway_rest_api.scanner_api.execution_arn
  lambda_role_arn    = aws_iam_role.lambda_role.arn
  subnet_ids         = module.scannerfleet_vpc.subnet_ids
  security_group_ids = module.scannerfleet_vpc.security_group_ids
  db_endpoint        = aws_db_instance.scannerfleet_db.endpoint
}


// Outputs

output "base_url" {
  value = aws_api_gateway_deployment.scanner_deployment.invoke_url
}

output "pg_endpoint" {
  value = aws_db_instance.scannerfleet_db.endpoint
}

output "s3_bucket" {
  value = module.lambda_s3_bucket.id
}
