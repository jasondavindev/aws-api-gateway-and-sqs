resource "aws_iam_role" "apig-sqs-send-msg-role" {
  name = "${var.app_name}-apig-sqs-send-msg-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "apig-sqs-send-msg-policy" {
  name        = "${var.app_name}-apig-sqs-send-msg-policy"
  description = "Policy allowing APIG to write to SQS for ${var.app_name}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": [
          "*"
      ],
      "Action": [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
      ]
    },
    {
      "Effect": "Allow",
      "Action": "sqs:SendMessage",
      "Resource": "${var.queue_arn}"
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "apig_sqs_policy_attach" {
  name = "${var.app_name}-iam-policy-attach"
  roles = ["${aws_iam_role.apig-sqs-send-msg-role.id}"]
  policy_arn = "${aws_iam_policy.apig-sqs-send-msg-policy.arn}"
}
