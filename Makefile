# if required to start the base linux machine. Provide these environment vars.
UN="$(shell whoami)"
UID=100
GID=100
DOCKER_GROUP_ID=1000

# check to see if the application scopeed network has been initialised.
export DOCKER_INITIALISED="$(docker network ls | grep knote)"

# check to see if any docker applications are present
export DOCKER_RUNNING_PROCESSES="$(docker ps | grep -Eo '(knote|mongo|minio) | sort -u')"

default: run-all

initialise_knote_network:
ifeq ($(strip $(DOCKER_INITIALISED)),)
	docker network create knote
endif
.PHONY: initialise_knote_network

mongo-run: initialise_knote_network
	docker run --name=mongo --network=knote --rm -d mongo
.PHONY: mongo-run

# knote app v1
app-run-v1: initialise_knote_network
	docker run --name=knote --network=knote --rm -p 3000:3000 -e MONGO_URL=mongodb://mongo:27017/dev -d knote
.PHONY: app-run

app-run-v2: initialise_knote_network
	docker run \
	--name=knote \
	--rm \
	--network=knote \
	-p 3000:3000 \
	-e MONGO_URL=mongodb://mongo:27017/dev \
	-e MINIO_ACCESS_KEY=${} \
	-e MINIO_SECRET_KEY=${} \
	-e MINIO_HOST=minio \
	knote:2.0

run-all:
	$(MAKE) mongo-run
	$(MAKE) app-run-v2
.PHONY: run-all