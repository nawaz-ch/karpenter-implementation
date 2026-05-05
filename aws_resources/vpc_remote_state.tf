data "terraform_remote_state" "vpc_remote_state" {
  backend = "s3"

  config = {
    bucket="tfstate-dev-us-east-1-17"
    key="vpc/dev/terraform.tfstate"
    region=var.aws_region
  }
}


output "vpc_id" {
  value = data.terraform_remote_state.vpc_remote_state.outputs.vpc_id
}

# --------------------------------------------------------------------
# Output the list of private subnets from the VPC
# --------------------------------------------------------------------
output "private_subnet_ids" {
  value = data.terraform_remote_state.vpc_remote_state.outputs.private_subnet_ids
}


# --------------------------------------------------------------------
# Output the list of public subnets from the VPC
# --------------------------------------------------------------------
output "public_subnet_ids" {
  value = data.terraform_remote_state.vpc_remote_state.outputs.public_subnet_ids
}
