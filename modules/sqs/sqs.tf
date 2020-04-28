resource "aws_sqs_queue" "queue" {
  name                       = "${var.queue_name}"
  visibility_timeout_seconds = 300
}
