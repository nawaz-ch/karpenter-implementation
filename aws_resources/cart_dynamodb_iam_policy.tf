resource "aws_iam_role" "read_dynamodb" {
  name = "read_dynamodb_role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    "Version":"2012-10-17",		 	 	 
    "Statement": [
        {
            "Sid": "AllowEksAuthToAssumeRoleForPodIdentity",
            "Effect": "Allow",
            "Principal": {
                "Service": "pods.eks.amazonaws.com"
            },
            "Action": [
                "sts:AssumeRole",
                "sts:TagSession"
            ]
        }
    ]
})

}


resource "aws_iam_policy" "dynamodb_read_policy" {
  name        = "dynamodb_read_policy"
  path        = "/"
  description = "My test policy"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:CreateTable",
          "dynamodb:DeleteTable",
          "dynamodb:DescribeTable",
          "dynamodb:UpdateTable",
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:UpdateItem",
          "dynamodb:BatchGetItem",
          "dynamodb:BatchWriteItem",
          "dynamodb:DescribeTimeToLive",
          "dynamodb:ListTables",
          "dynamodb:ListTagsOfResource"
        ]
        Resource = "*"  # Full access to all DynamoDB resources in all regions
      }
    ]
  })
}


resource "aws_iam_policy_attachment" "attach_dynamodb_policy" {
  name       = "attach_dynamodb_policy"
 
  roles      = [aws_iam_role.read_dynamodb.name]

  policy_arn = aws_iam_policy.dynamodb_read_policy.arn
}



resource "aws_eks_pod_identity_association" "carts" {
  cluster_name    = data.terraform_remote_state.eks_remote_state.outputs.eks_cluster_name
  namespace       = "default"
  service_account = "carts"
  role_arn        = aws_iam_role.read_dynamodb.arn
}