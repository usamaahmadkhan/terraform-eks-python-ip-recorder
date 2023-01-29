terraform {
  # https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest
  source = "tfr:///terraform-aws-modules/eks/aws?version=19.5.1"
  after_hook "terragrunt-read-config" {
    commands = ["apply"]
    execute  = ["bash", "./script.sh"]
  }
  extra_arguments "set_env" {
    commands = ["apply"]
    env_vars = {
      KUBECONFIG_PATH = "${local.env_vars.locals.kube_config_path_base}/.kube/eksctl/clusters/${local.env_vars.locals.cluster_name}"
      CLUSTER_NAME = local.env_vars.locals.cluster_name
    }
  }
}

locals {
  env_vars = read_terragrunt_config("${get_path_to_repo_root()}//terragrunt")
}