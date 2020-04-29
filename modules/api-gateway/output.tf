output "ip" {
  value = "${aws_api_gateway_deployment.api_deployment.invoke_url}"
}

output "api_id" {
  value = "${aws_api_gateway_rest_api.example_api.id}"
}

output "api_resource_id" {
  value = "${aws_api_gateway_rest_api.example_api.root_resource_id}"
}
