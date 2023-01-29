include "eks" {
  path = "${get_path_to_repo_root()}//terragrunt/modules/eks/terragrunt.hcl"
}

locals {
  env_vars = read_terragrunt_config("${get_path_to_repo_root()}//terragrunt")
}

dependency "vpc" {
  config_path = "${get_path_to_repo_root()}//terragrunt/infra/vpc"
}

inputs = {
  cluster_version = local.env_vars.locals.cluster_version
  cluster_name    = local.env_vars.locals.cluster_name
  vpc_id          = dependency.vpc.outputs.vpc_id
  subnet_ids      = dependency.vpc.outputs.private_subnets

  cluster_endpoint_public_access = true
  cluster_endpoint_private_access = true

  enable_irsa	= true

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    instance_types = ["t2.micro"]
  }

  eks_managed_node_groups = {
    apps = {
      min_size     = 1
      max_size     = 1
      desired_size = 1

      instance_types = ["t2.micro"]
      capacity_type  = "SPOT"
    }
  }

  aws_auth_users = [
    {
      userarn  = "arn:aws:iam::${local.env_vars.locals.account_id}:user/terraform-user"
      username = "terraform-user"
      groups   = ["system:masters"]
    },
  ]

  create_aws_auth_configmap = true
  manage_aws_auth_configmap = true
  
  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}

generate "k8s-provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
provider "kubernetes" {
  host                   = aws_eks_cluster.this[0].endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.this[0].certificate_authority[0].data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.this[0].id]
    command     = "aws"
  }
}
EOF
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
