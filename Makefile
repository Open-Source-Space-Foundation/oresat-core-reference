.PHONY: all
all: submodules fprime-venv generate-if-needed build

.PHONY: help
help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Dependencies

.PHONY: submodules
submodules: ## Initialize and update git submodules
	@git submodule update --init --recursive

export VIRTUAL_ENV ?= $(shell pwd)/fprime-venv
.PHONY: fprime-venv
fprime-venv: uv ## Create a virtual environment
	@$(UV) venv fprime-venv --allow-existing
	@$(UV) pip install --prerelease=allow --requirement requirements.txt

fprime-venv-docker: build-image ## Create a virtual environment for cross-compilation image
	@$(DOCKER_RUN) uv venv fprime-venv-docker --allow-existing
	@$(DOCKER_RUN) uv pip install --prerelease=allow --requirement requirements.txt

##@ Development

.PHONY: pre-commit-install
pre-commit-install: uv ## Install pre-commit hooks
	@$(UVX) pre-commit install > /dev/null

.PHONY: fmt
fmt: pre-commit-install ## Lint and format files
	@$(UVX) pre-commit run --all-files

.PHONY: generate
generate: submodules fprime-venv-docker ## Generate F Prime OreSat Core Reference
	@$(DOCKER_UV_RUN) fprime-util generate --force

.PHONY: generate-if-needed
BUILD_DIR ?= $(shell pwd)/build-fprime-automatic-arm-hf-linux
generate-if-needed:
	@test -d $(BUILD_DIR) || $(MAKE) generate

.PHONY: build
build: submodules fprime-venv-docker generate-if-needed ## Build F Prime OreSat Core Reference
	@$(DOCKER_UV_RUN) fprime-util build

.PHONY: clean
clean: ## Remove all gitignored files
	git clean -dfX

##@ Operations

GDS_COMMAND ?= $(UV_RUN) fprime-gds

.PHONY: gds
gds: ## Run FPrime GDS
	@echo "Running FPrime GDS..."
	@if [ -n "$(UART_DEVICE)" ]; then \
		echo "Using UART_DEVICE=$(UART_DEVICE)"; \
		$(GDS_COMMAND) --uart-device $(UART_DEVICE); \
	fi
	$(GDS_COMMAND)

.PHONY: delete-shadow-gds
delete-shadow-gds:
	@echo "Deleting shadow GDS..."
	@$(UV_RUN) pkill -9 -f fprime_gds
	@$(UV_RUN) pkill -9 -f fprime-gds

include lib/makelib/build-tools.mk
