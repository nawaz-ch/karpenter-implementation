variable "aws_region" {
    description="aws region to deploy resources"
    type=string
    default="us-east-1"
}


variable "business_division" {
    description="owner"
    type=string
    default="retail"
}

variable "environment_name" {
    description="env"
    type=string
    default="dev"
}