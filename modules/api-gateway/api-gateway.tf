resource "aws_api_gateway_rest_api" "example_api" {
  name = "${var.api_name}"
}

resource "aws_api_gateway_resource" "message_resource" {
  path_part   = "messages"
  parent_id   = "${aws_api_gateway_rest_api.example_api.root_resource_id}"
  rest_api_id = "${aws_api_gateway_rest_api.example_api.id}"
}

resource "aws_api_gateway_method" "messages_post_method" {
  rest_api_id   = "${aws_api_gateway_rest_api.example_api.id}"
  resource_id   = "${aws_api_gateway_resource.message_resource.id}"
  http_method   = "POST"
  authorization = "NONE"
  request_parameters = {
    "method.request.querystring.QueueUrl" = true
  }
}

resource "aws_api_gateway_integration" "messages_post_integration" {
  rest_api_id             = "${aws_api_gateway_rest_api.example_api.id}"
  resource_id             = "${aws_api_gateway_resource.message_resource.id}"
  http_method             = "${aws_api_gateway_method.messages_post_method.http_method}"
  integration_http_method = "POST"
  type                    = "AWS"
  credentials             = "${var.iam_role_arn}"
  uri                     = "arn:aws:apigateway:${var.region}:sqs:action/SendMessage"

  request_parameters = {
    "integration.request.querystring.QueueUrl" = "'${var.queue_url}'"
    "integration.request.querystring.MessageBody" = "method.request.body.body"
  }
}

resource "aws_api_gateway_method_response" "messages_post_method_response_200" {
  rest_api_id = "${aws_api_gateway_rest_api.example_api.id}"
  resource_id = "${aws_api_gateway_resource.message_resource.id}"
  http_method = "${aws_api_gateway_method.messages_post_method.http_method}"
  status_code = "200"
  response_parameters = "${var.method_response_parameters}"
}

resource "aws_api_gateway_integration_response" "messages_post_integration_response_200" {
  rest_api_id = "${aws_api_gateway_rest_api.example_api.id}"
  resource_id = "${aws_api_gateway_resource.message_resource.id}"
  http_method = "${aws_api_gateway_method.messages_post_method.http_method}"
  status_code = "${aws_api_gateway_method_response.messages_post_method_response_200.status_code}"
  response_parameters = "${var.integration_response_parameters}"
  depends_on  = [
    "aws_api_gateway_resource.message_resource",
    "aws_api_gateway_method.messages_post_method",
    "aws_api_gateway_method_response.messages_post_method_response_200"
  ]
}

resource "aws_api_gateway_deployment" "api_deployment" {
  rest_api_id = "${aws_api_gateway_rest_api.example_api.id}"
  stage_name  = "dev"
  depends_on  = [
    "aws_api_gateway_integration.messages_post_integration",
    "aws_api_gateway_integration_response.messages_post_integration_response_200"
  ]
}

resource "aws_api_gateway_usage_plan" "api_usage_plan" {
  name         = "${var.app_name}-usage-plan"

  api_stages {
    api_id = "${aws_api_gateway_rest_api.example_api.id}"
    stage  = "${aws_api_gateway_deployment.api_deployment.stage_name}"
  }

  quota_settings {
    limit  = 20
    offset = 2
    period = "WEEK"
  }

  throttle_settings {
    burst_limit = 5
    rate_limit  = 10
  }
}
