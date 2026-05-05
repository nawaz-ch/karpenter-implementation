resource "aws_iam_policy" "read_secrets_policy" {
  name        =  "read_secrets_policy"
  path        = "/"
  description = "My test policy"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "SecretsManagerGetAndDescribeSecret",
            "Effect": "Allow",
            "Action": [
                "secretsmanager:GetSecretValue",
                "secretsmanager:DescribeSecret"
            ],
            "Resource": "arn:aws:secretsmanager:${var.aws_region}:${data.aws_caller_identity.current.account_id}:secret:retail-store-db-secret-*"
        }
    ]
})
}


resource "aws_iam_policy_attachment" "read_secrets_policy_attachment" {
  name       = "read_secrets_policy_attachment"
  roles      = [aws_iam_role.secrets_read_role.name]
  policy_arn = aws_iam_policy.read_secrets_policy.arn
}