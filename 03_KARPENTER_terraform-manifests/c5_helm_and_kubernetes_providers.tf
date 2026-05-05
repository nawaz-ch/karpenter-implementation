# Datasource: EKS Cluster Auth 
data "aws_eks_cluster_auth" "cluster" {
  name = data.terraform_remote_state.eks.outputs.eks_cluster_name
}


data "aws_ecrpublic_authorization_token" "token" {
  provider = aws.us_east_1
}



# HELM Provider 
provider "helm" {
  kubernetes = {
    host                   = data.terraform_remote_state.eks.outputs.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(data.terraform_remote_state.eks.outputs.eks_cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }

  registries = [
    {
      url      = "oci://public.ecr.aws"
      username = data.aws_ecrpublic_authorization_token.token.user_name
      password = data.aws_ecrpublic_authorization_token.token.password
    }
  ]
}

# Terraform Kubernetes Provider
provider "kubernetes" {
  host = data.terraform_remote_state.eks.outputs.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(data.terraform_remote_state.eks.outputs.eks_cluster_certificate_authority_data)
  token = data.aws_eks_cluster_auth.cluster.token
}


