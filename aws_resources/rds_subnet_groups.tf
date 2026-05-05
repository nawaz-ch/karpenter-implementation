resource "aws_db_subnet_group" "redis_subnet_group" {
  name       = "rds_subnet_group"
  subnet_ids = data.terraform_remote_state.vpc_remote_state.outputs.private_subnet_ids

  tags = {
    Name = "My DB subnet group"
  }
}