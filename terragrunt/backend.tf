# Generated by Terragrunt. Sig: nIlQXj57tbuaRZEa
terraform {
  required_version = "~> 1.3.7"
  backend "s3" {
    bucket         = "ip-recorder-state"
    key            = "ip-recorder-us-east-1.k8s.local/python-public-ip-recorder/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}
