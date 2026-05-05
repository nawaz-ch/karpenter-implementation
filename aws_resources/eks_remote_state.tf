data "terraform_remote_state" "eks_remote_state" {
    backend="s3"
    config = {
     bucket="tfstate-dev-us-east-1-17"
     key="eks/dev/terraform.tfstate"
     region=var.aws_region
    }
}