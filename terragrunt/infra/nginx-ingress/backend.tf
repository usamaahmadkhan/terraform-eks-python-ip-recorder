# Generated by Terragrunt. Sig: nIlQXj57tbuaRZEa
terraform {
  backend "s3" {
    bucket  = "ip-recorder-state"
    encrypt = true
    key     = "ip-recorder-us-east-1.k8s.local/python-public-ip-recorder/terragrunt/infra/nginx-ingress/terraform.tfstate"
    region  = "us-east-1"
  }
}
