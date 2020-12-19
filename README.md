# Fleet Scan Management API

## Build & Deploy

Install Terraform [Here](https://learn.hashicorp.com/tutorials/terraform/install-cli)

Install AWS Cli [Here](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)

Ensure that you have some valid AWS Credentials stored locally. If doing a new deployment, you should 
change the name of the bucket for the functions.

If you're on Linux or OSX, you can just execute the `build.sh`. Just ask me for the PG DB Credentials.
If you're on Windows, you will have to clear the build folder yourself before building and deploying.


## Overview

This infrastructure uses several components of AWS to ensure that the platform is scalable and manageable in the long run. There are terraform modules to help assist with packaging the functions, uploading them to S3, creating the vpc, creating the lambdas + permissions + cloudwatch logs.

The lambdas operate within a VPC with 3 subnets and can communicate with the postgresql database in RDS securely.

If you wanted to add a new endpoint, you would create a new file in `src` with the name of your function `do-something.ts` and export a function called `handler`. Then, you add the following into `infrastructure/main.tf`:

```
module "do_something_service" {
  source = "./modules/service"
  name = "do-something"
  bucket_id = module.lambda_s3_bucket.id
  bucket = module.lambda_s3_bucket.bucket
  rest_api_id = aws_api_gateway_rest_api.scanner_api.id
  parent_resource_id = aws_api_gateway_resource.scanner_resource.id
  api_execution_arn = aws_api_gateway_rest_api.scanner_api.execution_arn
  lambda_role_arn = aws_iam_role.lambda_role.arn
}
```

I could have just created a simple express server and stuck it on Digital Ocean but I wanted to use the opportunity to showcase my ability to learn technologies as required, which is a trait that's important operating in the business of startups.

This is my first attempt at creating a terraform infrastructure from scratch and I've consulted my friends who have more experience to offer me tips with best practices, an approach I typically use when dealing with an unfamiliar technology.


## Testing Locally

# Invoking function with event file
$ sam local invoke "track-scan" -e event.json

# Invoking function with event via stdin
$ echo '{...scan-data}' | sam local invoke --event - "track-scan"

# For more options
$ sam local invoke --help
