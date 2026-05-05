resource "aws_security_group" "eks_postgresdb_traffic" {
  name        = "allow_ekspostgresdb_db_traffic"
  description = "Allow eks db traffic"
  vpc_id      = data.terraform_remote_state.vpc_remote_state.outputs.vpc_id

  tags = {
    Name = "allow_db_traffic"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_postgresdb_traffic" {
 security_group_id=aws_security_group.eks_postgresdb_traffic.id
  from_port         = 5432
  ip_protocol       = "tcp"
  to_port           = 5432
  referenced_security_group_id=data.terraform_remote_state.eks_remote_state.outputs.cluster_security_group_id
}



resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_outside_postgres" {
 security_group_id=aws_security_group.eks_postgresdb_traffic.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  from_port=0
  to_port=0 # semantically equivalent to all ports
}
