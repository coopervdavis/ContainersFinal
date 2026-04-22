

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = "nhl-vpc"
  cidr = "10.0.0.0/16"

  azs            = ["us-east-2a", "us-east-2b"]
  public_subnets = ["10.0.101.0/24", "10.0.102.0/24"]

  # For RDS
  database_subnets                   = ["10.0.201.0/24", "10.0.202.0/24"]
  create_database_subnet_group       = true
  create_database_subnet_route_table = true
}
