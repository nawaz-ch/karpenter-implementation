resource "aws_iam_role" "orders_get_credentials_role" {
  name = "orders_get_credentials_role"

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


resource "aws_iam_policy" "orders_get_credentials_policy" {
  name        = "orders_get_credentials_policy"
  path        = "/"
  description = "orders_get_credentials_policy"

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


resource "aws_iam_policy_attachment" "read_credentials_policy_attachment" {
  name       = "read_credentials_policy_attachment"
  roles      = [aws_iam_role.orders_get_credentials_role.name]
  policy_arn = aws_iam_policy.orders_get_credentials_policy.arn
}


resource "aws_eks_pod_identity_association" "orders" {
  cluster_name    = data.terraform_remote_state.eks_remote_state.outputs.eks_cluster_name
  namespace       = "default"
  service_account = "orders"
  role_arn        = aws_iam_role.orders_get_credentials_role.arn
}