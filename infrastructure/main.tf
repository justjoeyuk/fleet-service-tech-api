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
  vpc_security_group_ids = [module.scannerfleet_vpc.bastion_security_group_id]
  skip_final_snapshot    = true
  publicly_accessible    = false
}

data "aws_ami" "latest_ecs" {
  most_recent = true
  owners = ["591542846629"] # AWS

  filter {
      name   = "name"
      values = ["*amazon-ecs-optimized"]
  }

  filter {
      name   = "virtualization-type"
      values = ["hvm"]
  }  
}

resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.latest_ecs.id
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  vpc_security_group_ids = [module.scannerfleet_vpc.bastion_security_group_id]
  subnet_id = module.scannerfleet_vpc.subnet1_id
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
  ]

  rest_api_id = aws_api_gateway_rest_api.scanner_api.id
  stage_name  = "production"
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

resource "aws_key_pair" "bastion_key" {
  key_name   = "bastion_rsa_key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCcPrFBTePnqrZYeosiv+mZWeaVoVT16wgnCP8TR9bmJT6YNX7pdxpvFZn22WyC0+T7gZ48tVrBEcuYJYKUGiET2WlT/3+bjQWLcN47hoomiVhg9FqVuhxsxloRUNx/Qd2OxL+iFz7xTJklSvJbIa+6HR7lsdf0sfXimueoPhszmgWv7rdGuiByS3RJGkIy+0S27AJTXJl4nwWCL67Yl0Ddtd24hPTRNu2NgXn6xjJYonUv94qRur9hjtexOiEh3F7dfjOi5shgy82lI33hqmmP01h6rdiedgYzQhZ/mV3tUeCfTx6Uxo4ZFYjbMBW0hz1pt3Dtyw/Mfrqjg32T3d8qrz+UhDvLufhPTkXFi+sb3VveZaFKkHnRYq1fpfGpsUacU1AWdcmFMlqrUa0d01f+DfZZjeBhXArI8M9g/KI25Ebkq2w04dGDcPZU8WSs8x9TjN29xMX6zEgt6TMb87fcw8jl1yRJtn7q+nu0lO33XDlNLhl0aqxt6tyUoe51ukhEaKeWoCdG46ClLCzQqfKt5r5GkoLOWmUFvVn/RcYPliSjaBeJLkJ9nlR1QxGT1uGVv9ta+Gntnwv+/Xu4pvIHurEGPHmUX4ELvZ2bBE/j67c2faKTsc2jGW5GtLZmFQjw4AUoNF6K7sr5Jp3eC5u6jG9tqpsol9KzzZhKuERUeQ== joey.clover@gmail.com"
}

output "base_url" {
  value = aws_api_gateway_deployment.scanner_deployment.invoke_url
}

output "pg_endpoint" {
  value = aws_db_instance.scannerfleet_db.endpoint
}

output "s3_bucket" {
  value = module.lambda_s3_bucket.id
}

output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}
