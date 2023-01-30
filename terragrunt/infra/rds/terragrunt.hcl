include "rds" {
  path = "${dirname(get_repo_root())}/${basename(get_repo_root())}//terragrunt/modules/rds/terragrunt.hcl"
}

locals {
  env_vars = read_terragrunt_config("${get_path_to_repo_root()}//terragrunt/infra")
}

dependency "vpc" {
  config_path = "${get_path_to_repo_root()}//terragrunt/infra/vpc"
}

dependency "eks" {
  config_path = "${get_path_to_repo_root()}//terragrunt/infra/eks"
}


inputs = {
  
  identifier = "${local.env_vars.locals.cluster_name}-db"

  engine = "mysql"
  engine_version = "5.7"
  instance_class = "db.t3.micro"
  allocated_storage = 20

  db_name  = "ips"
  username = "user"
  port     = "3306"

  create_random_password = true
  
  iam_database_authentication_enabled = true

  db_subnet_group_name = dependency.vpc.outputs.database_subnet_group_name
  vpc_security_group_ids = [dependency.vpc.outputs.default_security_group_id, dependency.eks.outputs.node_security_group_id]

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }

  # DB subnet group
  create_db_subnet_group = false
  subnet_ids             = dependency.vpc.outputs.database_subnets

  # DB parameter group
  family = "mysql5.7"

  # DB option group
  major_engine_version = "5.7"

  # Database Deletion Protection
  deletion_protection = false

}

remote_state {
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  backend = local.env_vars.remote_state.backend
  config = merge(
    local.env_vars.remote_state.config,
    {
      key = "${local.env_vars.locals.cluster_full_name}/${basename(get_repo_root())}/${get_path_from_repo_root()}/terraform.tfstate"
    },
  )
}

generate = local.env_vars.generate
