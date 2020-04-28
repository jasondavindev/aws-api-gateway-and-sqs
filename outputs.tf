output "api_ip" {
  value = "${module.api_gateway.ip}"
}

output "queue_url" {
  value = "${module.sqs.queue_url}"
}
