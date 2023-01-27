.PHONY: default build builder-image binary-image test stop clean-images clean push apply deploy release release-all manifest push clean-image

REGISTRY ?= docker.io
DOCKER_IMAGE ?= usamaahmadkhan/ip-recorder

# Default value "dev"
DOCKER_TAG ?= dev
REPOSITORY_DOCKER_TAG = ${REGISTRY}/${DOCKER_IMAGE}:${DOCKER_TAG}

VERSION ?= 0.0.1

build:
	docker build -t "${REPOSITORY_DOCKER_TAG}" .

push:
	docker push ${REPOSITORY_DOCKER_TAG}

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