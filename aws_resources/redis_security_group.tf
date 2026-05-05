resource "aws_security_group" "redis_sg" {
  name        = "redis_sg"
  description = "redis_sg"
  vpc_id      = data.terraform_remote_state.vpc_remote_state.outputs.vpc_id

 
}

resource "aws_vpc_security_group_ingress_rule" "allow_traffic_to_redis" {
  security_group_id = aws_security_group.redis_sg.id
  from_port         = 6379
  ip_protocol       = "tcp"
  to_port           = 6379
  referenced_security_group_id=data.terraform_remote_state.eks_remote_state.outputs.cluster_security_group_id
}

resource "aws_vpc_security_group_egress_rule" "allow_traffic_outside_redis" {
 security_group_id = aws_security_group.redis_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  from_port=0
  to_port=0 # semantically equivalent to all ports
}


