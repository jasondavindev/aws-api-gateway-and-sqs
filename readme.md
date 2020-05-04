# API Gateway and SQS integration

This repository makes a integration with AWS resources (SQS and API Gateway). The infrastructure is provisioned by Terraform.

## Features
- API Throttling and rate limit
- CORS configuration
- Sends headers, query params, params, user IP and body param from request to SQS queue
