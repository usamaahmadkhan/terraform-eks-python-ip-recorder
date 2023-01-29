# IP-Recorder Application using EKS/RDS


## Quick Start

```
# Bring Up whole Infra
make infra-up

# Find ECR URL and replace in Makefile
cd terragrunt/infra/ecr; terragrunt output repository_url

# Build and Push the image
make build-push

# Find Postgres Password and create db-password
PASSWORD=$(cd terragrunt/infra/rds; terragrunt output db_instance_password)
kubectl create secret generic --from-literal=$(PASSWORD) -n <NAMESPACE>

# Build and Push the image
make build-push

# 

```
## Directory Structure

`deployments/chart` contains Helm chart for ip-recorder app
`deployments/all-in-one` contains single file templated from the helm chart for easy apply
`terragrunt/` contains Infrastructure modules for VPC/EKS/RDS etc. along with Nginx-ingress-controller and AWS Load Balancer Controller 


```
.
├── deployments
│   ├── all-in-one
│   │   └── ip-recorder.yaml
│   └── chart
│       └── ip-recorder
│           ├── charts
│           ├── Chart.yaml
│           ├── templates
│           │   ├── deployment.yaml
│           │   ├── _helpers.tpl
│           │   ├── hpa.yaml
│           │   ├── ingress.yaml
│           │   ├── NOTES.txt
│           │   ├── serviceaccount.yaml
│           │   ├── service.yaml
│           │   └── tests
│           │       └── test-connection.yaml
│           └── values.yaml
├── docker-compose.yml
├── Dockerfile
├── gunicorn.sh
├── html
│   └── list.html
├── main.py
├── Makefile
├── REAME.md
├── requirements.txt
└── terragrunt
    ├── backend.tf
    ├── infra
    │   ├── aws-lb-controller
    │   │   └── terragrunt.hcl
    │   ├── ecr
    │   │   └── terragrunt.hcl
    │   ├── eks
    │   │   ├── script.sh
    │   │   └── terragrunt.hcl
    │   ├── nginx-ingress
    │   │   ├── backend.tf
    │   │   ├── helm-chart.tf
    │   │   ├── provider.tf
    │   │   ├── terragrunt.hcl
    │   │   └── values.yaml
    │   ├── rds
    │   │   └── terragrunt.hcl
    │   └── vpc
    │       └── terragrunt.hcl
    ├── modules
    │   ├── aws-lb-controller
    │   │   ├── terragrunt.hcl
    │   │   └── variables.tf
    │   ├── ecr
    │   │   └── terragrunt.hcl
    │   ├── eks
    │   │   └── terragrunt.hcl
    │   ├── rds
    │   │   └── terragrunt.hcl
    │   └── vpc
    │       └── terragrunt.hcl
    ├── provider.tf
    └── terragrunt.hcl
```
##

TODOS:
- Separate out ECR IAMs . Now access for only `Administrator` group. Make separate Admin group with IAM users and separate RBAC for EKS Admins


Why a public endpoint access is enabled for EKS?

## Infrastructure

Pre-requisites:
- `terraform`
- `terragrunt`
- `awscli`
- `eksctl`

### Build Up Everything

The following command will create
- 1x VPC (2x Private, 2x Public subnets in`us-east-1` region)
- 1x EKS (1xNodeGroup)
- 1x RDS (MySQL instance)
- 1x ECR reository
- AWS Load Balancer Deployment in EKS
- Nginx Ingress Deployment in EKS

```
make infra-up
```

### Tear Down
```
```
make infra-down
```

```

## Running Locally

Pre-requisites:
- `make`
- `docker-compose`
- `docker`

```
make run
```
