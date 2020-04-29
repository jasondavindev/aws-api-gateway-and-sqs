locals {
  headers = map(
    "Access-Control-Allow-Headers",       "'${join(",", var.allow_headers)}'",
    "Access-Control-Allow-Methods",       "'${join(",", var.allow_methods)}'",
    "Access-Control-Allow-Origin",        "'${join(",", var.allow_origins)}'",
    "Access-Control-Max-Age",             "'${var.allow_max_age}'",
    "Access-Control-Allow-Credentials",   var.allow_credentials ? "'true'" : ""
  )

  valid_headers = matchkeys(
    keys(local.headers),
    values(local.headers),
    compact(values(local.headers))
  )

  header_names = formatlist("method.response.header.%s", local.valid_headers)

  true_list = split("|",
    replace(join("|", local.header_names), "/[^|]+/", "true")
  )

  integration_response_parameters = zipmap(
    local.header_names,
    compact(values(local.headers))
  )

  method_response_parameters = zipmap(
    local.header_names,
    local.true_list
  )
}

resource "aws_api_gateway_method" "cors_method" {
  rest_api_id   = "${var.api_id}"
  resource_id   = "${var.api_resource_id}"
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "cors_integration" {
  rest_api_id = "${var.api_id}"
  resource_id = "${var.api_resource_id}"
  http_method = "${aws_api_gateway_method.cors_method.http_method}"

  type = "MOCK"

  request_templates = {
    "application/json" = "{ \"statusCode\": 200 }"
  }
}

resource "aws_api_gateway_integration_response" "cors_integration_response" {
  rest_api_id = "${var.api_id}"
  resource_id = "${var.api_resource_id}"
  http_method = "${aws_api_gateway_method.cors_method.http_method}"
  status_code = 200

  response_parameters = local.integration_response_parameters

  depends_on = [
    aws_api_gateway_integration.cors_integration,
    aws_api_gateway_method_response.cors_integration_method_response,
  ]
}

resource "aws_api_gateway_method_response" "cors_integration_method_response" {
  rest_api_id = "${var.api_id}"
  resource_id = "${var.api_resource_id}"
  http_method = "${aws_api_gateway_method.cors_method.http_method}"
  status_code = 200

  response_parameters = local.method_response_parameters

  response_models = {
    "application/json" = "Empty"
  }

  depends_on = [
    aws_api_gateway_method.cors_method,
  ]
}
