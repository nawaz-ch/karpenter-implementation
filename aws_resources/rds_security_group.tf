resource "aws_security_group" "eks_db_traffic" {
  name        = "allow_eks_db_traffic"
  description = "Allow eks db traffic"
  vpc_id      = data.terraform_remote_state.vpc_remote_state.outputs.vpc_id

  tags = {
    Name = "allow_db_traffic"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_db_traffic" {
security_group_id=aws_security_group.eks_db_traffic.id
  from_port         = 3306
  ip_protocol       = "tcp"
  to_port           = 3306
  referenced_security_group_id=data.terraform_remote_state.eks_remote_state.outputs.cluster_security_group_id
}



resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
security_group_id=aws_security_group.eks_db_traffic.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  from_port=0
  to_port=0 # semantically equivalent to all ports
}

