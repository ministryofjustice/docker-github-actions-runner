build-old:
	docker buildx build --build-arg RUNNER_VERSION="2.278.0" --build-arg DOCKER_VERSION="19.03.13" --tag ministryofjustice/actions-runner:latest --tag ministryofjustice/actions-runner:v2.278.0 --platform linux/amd64 --file ./Dockerfile --load .

build:
	docker buildx build --no-cache --build-arg RUNNER_VERSION="2.278.0" --build-arg DOCKER_VERSION="19.03.13" --tag ministryofjustice/actions-runner:latest --tag ministryofjustice/actions-runner:v2.278.0 --platform linux/amd64 --file ./Dockerfile --load .

run:
	docker run -it --rm ministryofjustice/actions-runner:latest
