# IP-Recorder Application using EKS/RDS

## Pre-requisites
- `terraform`
- `terragrunt`
- `awscli`
- `eksctl`
- `jq`
- `helm`
- `docker`
- `docker-compose`

## Quick Start

```
# Bring Up whole Infra
make infra-up

# Find ECR URL and replace in Makefile
cd terragrunt/infra/ecr; terragrunt output repository_url

# Build and Push the image
make build-push

# Export KUBE CONFIG
export KUBECONFIG=$HOME/.kube/eksctl/clusters/<name>

# Update values in chart/ip-recorder/values.yaml file
# e.g. 1. image.repository
#      2. image.tag
#      3. env.DB_HOST
#      4. env.DB_PORT
#      5. env.DB_PASSWORD (Secret will be created in the next steps )
#      6. ingress.className (should be "nginx")
#      6. ingress.hosts.host (kubectl get svc ingress-nginx-controller -n nginx-ingress -ojson | jq -r .status.loadBalancer.ingress[0].hostname)

# Deploy Application
make manifests
make apply

# Find RDS Instance Password and create db-password
PASSWORD=$(cd terragrunt/infra/rds; terragrunt output db_instance_password | jq -r )
kubectl create secret generic db-password --from-literal=password=$PASSWORD -n <NAMESPACE>


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
│           │   └── service.yaml
│           └── values.yaml
├── docker-compose.yml
├── Dockerfile
├── gunicorn.sh
├── html
│   └── list.html
├── main.py
├── Makefile
├── README.md
├── requirements.txt
└── terragrunt
    ├── infra
    │   ├── aws-lb-controller
    │   │   └── terragrunt.hcl
    │   ├── backend.tf
    │   ├── ecr
    │   │   └── terragrunt.hcl
    │   ├── eks
    │   │   ├── script.sh
    │   │   └── terragrunt.hcl
    │   ├── nginx-ingress
    │   │   ├── backend.tf
    │   │   ├── errored.tfstate
    │   │   ├── helm-chart.tf
    │   │   ├── provider.tf
    │   │   ├── terragrunt.hcl
    │   │   └── values.yaml
    │   ├── provider.tf
    │   ├── rds
    │   │   └── terragrunt.hcl
    │   ├── terragrunt.hcl
    │   └── vpc
    │       └── terragrunt.hcl
    └── modules
        ├── aws-lb-controller
        │   ├── terragrunt.hcl
        │   └── variables.tf
        ├── ecr
        │   └── terragrunt.hcl
        ├── eks
        │   └── terragrunt.hcl
        ├── rds
        │   └── terragrunt.hcl
        └── vpc
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
