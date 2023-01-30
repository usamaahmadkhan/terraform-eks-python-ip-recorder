include "aws-lb-controller" {
  path = "${get_path_to_repo_root()}//terragrunt/modules/aws-lb-controller/terragrunt.hcl"
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

  role_name = "${local.env_vars.locals.cluster_name}_eks_lb"
  attach_load_balancer_controller_policy = true

  oidc_providers = {
    main = {
      provider_arn               = dependency.eks.outputs.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }
  
  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}


generate "helm-lb" {
  path      = "helm-lb.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
resource "kubernetes_service_account" "service-account" {
  metadata {
    name = "aws-load-balancer-controller"
    namespace = "kube-system"
    labels = {
        "app.kubernetes.io/name"= "aws-load-balancer-controller"
        "app.kubernetes.io/component"= "controller"
    }
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.this[0].arn
      "eks.amazonaws.com/sts-regional-endpoints" = "true"
    }
  }
}

resource "helm_release" "lb" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.4.7"
  namespace  = "kube-system"
  depends_on = [
    kubernetes_service_account.service-account
  ]

  set {
    name  = "replicaCount"
    value = 2
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "clusterName"
    value = "${local.env_vars.locals.cluster_name}"
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
