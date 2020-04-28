output "iam_role_arn" {
  value = "${aws_iam_role.apig-sqs-send-msg-role.arn}"
}
