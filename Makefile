BUILD_DIR_NAME = build

SOURCE_DIR = $(shell pwd)
DOCKER_IMAGE = room2352/vstbuild:latest
USER_ID = $(shell id -u ${USER})
GROUP_ID = $(shell id -g ${USER})

RM = rm -rf

DOCKER_FOR_BUILD = docker run --rm \
	-e LOCAL_UID=$(USER_ID) -e LOCAL_GID=$(GROUP_ID) -e CXX=g++ \
	-v $(SOURCE_DIR):/project \
	-w /project/$(BUILD_DIR_NAME) \
	$(DOCKER_IMAGE)

DOCKER_WITHOUT_MOUNT = docker run --rm \
	-e LOCAL_UID=$(USER_ID) -e LOCAL_GID=$(GROUP_ID) \
	$(DOCKER_IMAGE)

check:
	$(DOCKER_WITHOUT_MOUNT) cmake --version

configure: check
	mkdir -p $(BUILD_DIR_NAME)
	$(DOCKER_FOR_BUILD) cmake ../vst3sdk

build: configure
	echo UID:$(USER_ID) GID:$(GROUP_ID)
	$(DOCKER_FOR_BUILD) cmake ../vst3sdk
	$(DOCKER_FOR_BUILD) cmake --build . --config Release -- -j

.PHONY: clean
clean:
	$(DOCKER_FOR_BUILD) cmake --build . --target clean
	$(RM) $(BUILD_DIR_NAME)
