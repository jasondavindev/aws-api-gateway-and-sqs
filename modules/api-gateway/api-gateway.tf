resource "aws_api_gateway_rest_api" "myapp_apig" {
  name = "${var.api_name}"
}

resource "aws_api_gateway_resource" "webhook_shopify_resource" {
  path_part   = "shopify"
  parent_id   = "${aws_api_gateway_rest_api.myapp_apig.root_resource_id}"
  rest_api_id = "${aws_api_gateway_rest_api.myapp_apig.id}"
}

resource "aws_api_gateway_method" "webhook_shopify_post_method" {
  rest_api_id   = "${aws_api_gateway_rest_api.myapp_apig.id}"
  resource_id   = "${aws_api_gateway_resource.webhook_shopify_resource.id}"
  http_method   = "POST"
  authorization = "NONE"
  request_parameters = {
    "method.request.querystring.QueueUrl" = true
  }
}

resource "aws_api_gateway_integration" "webhook_shopify_post_integration" {
  rest_api_id             = "${aws_api_gateway_rest_api.myapp_apig.id}"
  resource_id             = "${aws_api_gateway_resource.webhook_shopify_resource.id}"
  http_method             = "${aws_api_gateway_method.webhook_shopify_post_method.http_method}"
  integration_http_method = "POST"
  type                    = "AWS"
  credentials             = "${var.iam_role_arn}"
  uri                     = "arn:aws:apigateway:${var.region}:sqs:action/SendMessage"

  request_parameters = {
    "integration.request.querystring.QueueUrl" = "'${var.queue_url}'"
    "integration.request.querystring.MessageBody" = "method.request.body.body"
  }
}

resource "aws_api_gateway_method_response" "webhook_shopify_post_method_response_200" {
  rest_api_id = "${aws_api_gateway_rest_api.myapp_apig.id}"
  resource_id = "${aws_api_gateway_resource.webhook_shopify_resource.id}"
  http_method = "${aws_api_gateway_method.webhook_shopify_post_method.http_method}"
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "webhook_shopify_post_integration_response_200" {
  rest_api_id = "${aws_api_gateway_rest_api.myapp_apig.id}"
  resource_id = "${aws_api_gateway_resource.webhook_shopify_resource.id}"
  http_method = "${aws_api_gateway_method.webhook_shopify_post_method.http_method}"
  status_code = "${aws_api_gateway_method_response.webhook_shopify_post_method_response_200.status_code}"
}

resource "aws_api_gateway_stage" "myapp_deployment_stage" {
  stage_name = "dev-temp"
  rest_api_id = "${aws_api_gateway_rest_api.myapp_apig.id}"
  deployment_id = "${aws_api_gateway_deployment.myapp_deployment.id}"
}

resource "aws_api_gateway_deployment" "myapp_deployment" {
  rest_api_id = "${aws_api_gateway_rest_api.myapp_apig.id}"
  stage_name = "dev"
  depends_on = ["aws_api_gateway_integration.webhook_shopify_post_integration"]
}
