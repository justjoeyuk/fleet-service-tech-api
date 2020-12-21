# Fleet Scan Management API

## Endpoints

Track a Scan - https://yjzt2jmqva.execute-api.us-east-1.amazonaws.com/production/scan/track-scan
``` POST: { payload in the spec }```

Get Scans - https://yjzt2jmqva.execute-api.us-east-1.amazonaws.com/production/scan/get-scans
``` POST: { device_id: number, from: string(iso date), to: string(iso date) }```

You can try the following payload:
```
{
    "device_id": 1608503246986,
    "from": "2020-12-20 00:00:00.000+00",
    "to": "2020-12-20 23:59:59.999+00"
}
```

You might be wondering why we're using `POST` for a function that should clearly be a "GET". That's just the downside of lambdas. They have a bunch of caching images and they don't really take nicely to HTTP Verbs when using them in an API capacity, ironically.

## Build & Deploy

`seed_db.js` and `src/pkg/DatabaseInstance` both have hard-coded passwords at the moment. I could use environment variables really easily for them but it's 2am so I'm taking some liberties. Ask me for the password and plug it in there first.

You'll also need the DB Username and Password for Terraform, which you can set as TF_ENV variables or enter then when you run `terraform apply` in the `infrastructure` directory.

Install Terraform [Here](https://learn.hashicorp.com/tutorials/terraform/install-cli)

Install AWS Cli [Here](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)

Ensure that you have some valid AWS Credentials stored locally. If doing a new deployment, you should 
change the name of the bucket for the functions.

If you're on Linux or OSX, you can just execute the `build.sh`. Just ask me for the PG DB Credentials.
If you're on Windows, you will have to clear the build folder yourself before building and deploying.


## Overview

This infrastructure uses several components of AWS to ensure that the platform is scalable and manageable in the long run. There are terraform modules to help assist with packaging the functions, uploading them to S3, creating the vpc, creating the lambdas + permissions + cloudwatch logs.

The RDS DB is inside a VPC fronted by an Internet Gateway, allowing communication to the outside world. I was going to go with a "Bastion" approach and improve security even more, but time isn't on my side.

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

At the moment, there aren't any unit tests in the project. I have seperated the logic into testable components, but with time constraints, I've not yet added them in. The best approach would be a dep 
injection for the ScanTracker.

I'm using a library called `runtypes` to allow runtime type checking for the requests and models. This makes it much easier to find issues with regards to requests and typings, especially when dealing with database queries.

I've used TypeScript due to my preference of using it over JS.


## Database

The database of choice is Postgres, simply because of the specification of the software. The way that the information could grow over time and the use case imply that relational may be the way to go. The tables in the DB are as follows:

```
CREATE TABLE IF NOT EXISTS scan_device (
   id BIGINT PRIMARY KEY
);

CREATE TABLE IF NOT EXISTS scan_result (
	id SERIAL PRIMARY KEY,
	scanning_device_id BIGINT,
  visible_device_id BIGINT,
	time TIMESTAMPTZ,
	interface TEXT,
	signal_strength SMALLINT,
	
	CONSTRAINT fk_scanning_device
    FOREIGN KEY(scanning_device_id) 
	  REFERENCES scan_device(id)
)
```

The table `scan_result` holds a foreign key reference to the `scan_device.id`. The `scan_device` table is not used yet, but is there in the case of adding extra details to the devices that are performing the scans.
