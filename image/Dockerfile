FROM --platform=$BUILDPLATFORM ubuntu:latest AS cross-compiler-downloader

ENV DEBIAN_FRONTEND=noninteractive
RUN apt update && \
	apt install -y --no-install-recommends \
		ca-certificates \
		curl \
		tar \
		xz-utils && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*

ARG ARM_TOOLS_VERSION=11.2-2022.02
ENV ARM_TOOLS_VERSION=${ARM_TOOLS_VERSION}

# Download cross compiler for amd64 to arm
FROM --platform=$BUILDPLATFORM cross-compiler-downloader AS x86_64-to-arm

RUN mkdir -p /opt/toolchains && \
	curl -Ls "https://developer.arm.com/-/media/Files/downloads/gnu/$ARM_TOOLS_VERSION/binrel/gcc-arm-$ARM_TOOLS_VERSION-x86_64-arm-none-linux-gnueabihf.tar.xz" | tar -JC /opt/toolchains --strip-components=1 -x

# Download cross compiler for arm64 to arm
FROM --platform=$BUILDPLATFORM cross-compiler-downloader AS aarch64-to-arm

RUN mkdir -p /opt/toolchains && \
	curl -Ls "https://developer.arm.com/-/media/Files/downloads/gnu/$ARM_TOOLS_VERSION/binrel/gcc-arm-$ARM_TOOLS_VERSION-aarch64-arm-none-linux-gnueabihf.tar.xz" | tar -JC /opt/toolchains --strip-components=1 -x

# Download UV
FROM --platform=$BUILDPLATFORM cross-compiler-downloader AS uv-downloader

ARG UV_VERSION=0.8.13
ENV UV_VERSION=${UV_VERSION}

RUN { curl -LsSf https://astral.sh/uv/${UV_VERSION}/install.sh | UNMANAGED_INSTALL=1 UV_INSTALL_DIR=/usr/local/bin/ sh > /dev/null; }

# Base image should match OreSat OS image
FROM --platform=$BUILDPLATFORM debian:bullseye AS builder

# Install CPP build tooling
ENV DEBIAN_FRONTEND=noninteractive
RUN apt update && \
	apt install -y --no-install-recommends \
		build-essential \
		cmake\
		default-jre \
		python3 \
		python3-venv && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*

# Copy cross compilers
COPY --from=x86_64-to-arm /opt/toolchains /opt/toolchains/x86_64-to-arm
COPY --from=aarch64-to-arm /opt/toolchains /opt/toolchains/aarch64-to-arm

# Copy UV
COPY --from=uv-downloader /usr/local/bin/uv /usr/local/bin/uv

# Copy entrypoint script
COPY --chmod=555 image/entrypoint.sh /entrypoint.sh

WORKDIR /workspace

ENV UV_CACHE_DIR=/workspace/.cache-docker/uv
ENV UV_LINK_MODE=copy
ENV UV_PYTHON=/usr/bin/python3

ENTRYPOINT [ "/entrypoint.sh" ]
