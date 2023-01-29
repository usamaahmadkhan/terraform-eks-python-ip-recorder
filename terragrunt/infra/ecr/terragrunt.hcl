include "ecr" {
  path = "${get_path_to_repo_root()}//terragrunt/modules/ecr/terragrunt.hcl"
}

locals {
  env_vars = read_terragrunt_config("${get_path_to_repo_root()}//terragrunt")
}

inputs = {

  repository_name = local.env_vars.locals.ecr_repo_name


  repository_read_write_access_arns = ["arn:aws:iam::${local.env_vars.locals.account_id}:group/Administrators"]
  repository_image_tag_mutability = "IMMUTABLE"
  repository_image_scan_on_push = true
  repository_encryption_type = "AES256"
  tags = {
    Terraform   = "true"
    Environment = "dev"
  }

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