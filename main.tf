locals {
  region   = "sa-east-1"
  app_name = "my_api_gtw"
}

data "aws_caller_identity" "current" {}

provider "aws" {
  region = "${local.region}"
}

module "api_gateway" {
  source       = "./modules/api-gateway"
  api_name     = "${local.app_name}-api"
  app_name     = "${local.app_name}"
  queue_name   = "${local.app_name}-queue"
  account_id   = "${data.aws_caller_identity.current.account_id}"
  iam_role_arn = "${module.policies.iam_role_arn}"
  region       = "${local.region}"
  queue_url    = "${module.sqs.queue_url}"
}

module "sqs" {
  source     = "./modules/sqs"
  queue_name = "${local.app_name}-queue"
}

module "policies" {
  source    = "./modules/policies"
  queue_arn = "${module.sqs.queue_arn}"
  app_name  = "${local.app_name}"
}

module "cors" {
  source = "./modules/cors"
  api_id = "${module.api_gateway.api_id}"
  api_resource_id = "${module.api_gateway.api_resource_id}"
}
