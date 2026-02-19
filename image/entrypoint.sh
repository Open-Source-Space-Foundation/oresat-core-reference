#!/usr/bin/env bash

export ARM_TOOLS_PATH="/opt/toolchains/$(uname -m)-to-arm"

exec "$@"
