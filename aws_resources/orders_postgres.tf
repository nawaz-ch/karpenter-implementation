resource "aws_db_instance" "orders_postgres" {
  identifier              = "orders-postgres-db"
  engine                  = "postgres"
  engine_version          = "17.6"
  instance_class          = "db.t4g.micro"
  allocated_storage       = 20
  max_allocated_storage   = 100
  db_subnet_group_name    = aws_db_subnet_group.orders_postgres_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.eks_postgresdb_traffic.id]

  db_name                 = "ordersdb"
  username                = local.retailstore_secret_json.username # Getting from c6_03 and AWS Secret Manager secret "retailstore-db-secret-1"
  password                = local.retailstore_secret_json.password # Getting from c6_03 and AWS Secret Manager secret "retailstore-db-secret-1"
  port                    = 5432

  multi_az                = false
  storage_encrypted       = true
  publicly_accessible     = false
  skip_final_snapshot     = true

  backup_retention_period = 7
  deletion_protection     = false

  tags = {
    Name = "${local.name}-orders-rds-postgres"
    Environment = var.environment_name
  }
}

