data "aws_secretsmanager_secret" "by_name" {
  name = "retail-store-db-secret-1"
}

data "aws_secretsmanager_secret_version" "secret_version" {
  secret_id = data.aws_secretsmanager_secret.by_name.id
}



locals {

    retailstore_secret_json=jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)

}