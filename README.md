# Fleet Scan Management API

## Build & Deploy

Install Terraform [Here](https://learn.hashicorp.com/tutorials/terraform/install-cli)

Install AWS Cli [Here](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)

Step 1: Ensure you have the AWS CLI setup with credentials for an account

Step 2: `npm run build`

Step 3: `.\deploy.sh`


## Testing Locally

# Invoking function with event file
$ sam local invoke "track-scan" -e event.json

# Invoking function with event via stdin
$ echo '{...scan-data}' | sam local invoke --event - "track-scan"

# For more options
$ sam local invoke --help
