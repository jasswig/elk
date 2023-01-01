
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy
# https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/QuickStartEC2Instance.html
resource "aws_iam_role_policy" "cloudwatch" {
  name = "fwd_logs_2_cloudwatch_policy"
  role = aws_iam_role.cloudwatch.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode(
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents",
            "logs:DescribeLogStreams"
           ],
          "Resource": [
            "*"
          ]
        }
      ]
    } 
  )
}

resource "aws_iam_role" "cloudwatch" {
  name = "fwd_logs_2_cloudwatch_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}


resource "aws_iam_instance_profile" "cloudwatch" {
  name = "fwd_logs_2_cloudwatch_profile"
  role = aws_iam_role.cloudwatch.name
}
