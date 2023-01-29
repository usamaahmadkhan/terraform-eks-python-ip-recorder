.PHONY: default build builder-image binary-image test stop clean-images clean push apply deploy release release-all manifest push clean-image

REGISTRY ?= 217104054449.dkr.ecr.us-east-1.amazonaws.com
DOCKER_IMAGE ?= ip-recorder

# Default value "dev"
VERSION ?= 0.0.1
REPOSITORY_DOCKER_TAG = ${REGISTRY}/${DOCKER_IMAGE}:${VERSION}


login:
	aws ecr get-login-password --region us-east-1 | docker login  --username AWS --password-stdin ${REGISTRY}

build:
	docker build -t "${REPOSITORY_DOCKER_TAG}" .

push:
	docker push ${REPOSITORY_DOCKER_TAG}

build-push: build push

apply:
	kubectl create ns temp-ip-recorder || kubectl kubectl apply -f deployments/manifests/ -n temp-ip-recorder

deploy: push apply

manifests: bump-chart
	helm template --release-name ip-recorder deployments/chart/ip-recorder/ > deployments/all-in-one/ip-recorder.yaml

bump-chart:
	sed -i "s/^version:.*/version: v$(VERSION)/" deployments/chart/ip-recorder/Chart.yaml
	sed -i "s/version:.*/version: v$(VERSION)/" deployments/chart/ip-recorder/values.yaml 
	sed -i "s/^appVersion:.*/appVersion: v$(VERSION)/" deployments/chart/ip-recorder/Chart.yaml
	sed -i "s/tag:.*/tag: v$(VERSION)/" deployments/chart/ip-recorder/values.yaml

run:
	docker-compose up --build