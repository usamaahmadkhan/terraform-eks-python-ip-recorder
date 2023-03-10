.PHONY: default login build push build-push apply purge deploy manifests bump-chart run infra-up infra-down

# cd terragrunt/infra/ecr; terragrunt output repository_url
REGISTRY ?= 217104054449.dkr.ecr.us-east-1.amazonaws.com
DOCKER_IMAGE ?= ip-recorder
NAMESPACE = ip-recorder

# Default value "dev"
VERSION ?= 0.0.4
REPOSITORY_DOCKER_TAG = ${REGISTRY}/${DOCKER_IMAGE}:v${VERSION}

ENVIRONMENT ?= infra 	# When multiple use dev, qa, prod etc. 

# Login to Image registry
login:
	aws ecr get-login-password --region us-east-1 | docker login  --username AWS --password-stdin ${REGISTRY}

# Build code locally
build:
	docker build -t "${REPOSITORY_DOCKER_TAG}" .

# Push to Image registry
push:
	docker push ${REPOSITORY_DOCKER_TAG}

# Build and Push to Registry
build-push: login build push

# Apply on live cluster
apply:
	kubectl create ns ${NAMESPACE} || true
	kubectl apply -f deployments/all-in-one/ip-recorder.yaml -n ${NAMESPACE}

# Purge from live cluster
purge:
	kubectl delete -f deployments/all-in-one/ip-recorder.yaml -n ${NAMESPACE}

# Deploy
deploy: push apply

# Prepare manifests
manifests: bump-chart
	helm template --namespace ${NAMESPACE} --release-name ip-recorder deployments/chart/ip-recorder/ > deployments/all-in-one/ip-recorder.yaml

# Bump Version
bump-chart:
	sed -i "s/^version:.*/version: v${VERSION}/" deployments/chart/ip-recorder/Chart.yaml
	sed -i "s/version:.*/version: v${VERSION}/" deployments/chart/ip-recorder/values.yaml 
	sed -i "s/^appVersion:.*/appVersion: v${VERSION}/" deployments/chart/ip-recorder/Chart.yaml
	sed -i "s/tag:.*/tag: v${VERSION}/" deployments/chart/ip-recorder/values.yaml

# Run locally
run:
	docker-compose up --build

# Bring up everything
infra-up:
	cd terragrunt/${ENVIRONMENT} && \
	terragrunt run-all apply

# Bring down everything
infra-down:
	cd terragrunt/${ENVIRONMENT} && \
	terragrunt run-all destroy