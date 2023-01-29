terraform {
  # https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest
  source = "tfr:///terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks?version=5.11.1"
                   
}