# resource "aws_eks_addon" "pod_identity_agent" {
#   cluster_name  = terraform_remote_state.eks_remote_state.outputs.eks_cluster_name
#   addon_name    = "eks-pod-identity-agent"
#   addon_version = "v1.3.7-eksbuild.2"  # use latest compatible version
# }

resource "aws_eks_pod_identity_association" "catalog" {
  cluster_name    = data.terraform_remote_state.eks_remote_state.outputs.eks_cluster_name
  namespace       = "default"
  service_account = "catalog"
  role_arn        = aws_iam_role.secrets_read_role.arn
}


# resource "aws_eks_pod_identity_association" "orders" {
#   cluster_name    = data.terraform_remote_state.eks_remote_state.outputs.eks_cluster_name
#   namespace       = "default"
#   service_account = "orders"
#   role_arn        = aws_iam_role.secrets_read_role.arn
# }