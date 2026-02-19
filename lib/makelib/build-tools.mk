##@ Build Tools

IMG ?= oresat-core-reference-builder:latest

# Ensure venv bin is on PATH so uv run can find fprime-util and other console scripts
DOCKER_RUN ?= docker run --rm -e VIRTUAL_ENV=/workspace/fprime-venv-docker -e PATH=/workspace/fprime-venv-docker/bin:$(PATH) -v $(shell pwd):/workspace -w /workspace $(IMG)
DOCKER_UV ?= $(DOCKER_RUN) uv
DOCKER_UVX ?= $(DOCKER_RUN) uvx
DOCKER_UV_RUN ?= $(DOCKER_RUN) uv run --python /workspace/fprime-venv-docker/bin/python

.PHONY: build-image
build-image: ## Build the Docker image for building FPrime OreSat Core Reference
	DOCKER_BUILDKIT=1 docker build -t $(IMG) -f image/Dockerfile .

.PHONY: download-bin
download-bin: uv

TOOLS_DIR ?= $(shell pwd)/bin
$(TOOLS_DIR):
	mkdir -p $(TOOLS_DIR)

### Tool Versions
UV_VERSION ?= 0.8.13

### uv & uvx
UV_DIR ?= $(TOOLS_DIR)/uv-$(UV_VERSION)
UV ?= $(UV_DIR)/uv
UVX ?= $(UV_DIR)/uvx
.PHONY: uv
uv: $(UV) ## Download uv
$(UV): $(TOOLS_DIR)
	@test -s $(UV) || { mkdir -p $(UV_DIR); curl -LsSf https://astral.sh/uv/$(UV_VERSION)/install.sh | UV_INSTALL_DIR=$(UV_DIR) sh > /dev/null; }

UV_RUN ?= $(UV) run --active
