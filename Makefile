# if required to start the base linux machine. Provide these environment vars.
UN="$(shell whoami)"
UID=100
GID=100
DOCKER_GROUP_ID=1000

# check to see if the application scopeed network has been initialised.
DOCKER_INITIALISED="$(docker network ls | grep knote)"

default: run-all

initialise_knote_network:
ifeq ($(strip ${DOCKER_INITIALISED}),)
	docker network create knote
endif
.PHONY: initialise_knote_network

mongo-run: initialise_knote_network
	docker run --name=mongo --network=knote --rm -d mongo
.PHONY: mongo-run

app-run: initialise_knote_network
	docker run --name=knote --network=knote -p 3000:3000 -e MONGO_URL=mongodb://mongo:27017/dev knote
.PHONY: app-run

run-all:
	$(MAKE) mongo-run
	$(MAKE) app-run
.PHONY: run-all