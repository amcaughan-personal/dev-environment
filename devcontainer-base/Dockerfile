# checkov:skip=CKV_DOCKER_2:Development environment, not a long-running service
# Base image for the org's dev containers: Ubuntu, the AWS CLI and mise, for linux/amd64 and
# linux/arm64. Published to ghcr.io/amcaughan-personal/devcontainer-base by
# .github/workflows/devcontainer-base.yml. Each repo's .devcontainer/Dockerfile starts from it
# (pinned by digest) and runs `mise install` for its own .tool-versions. Personal shell
# settings come from the dotfiles, not from here.
FROM ubuntu:24.04@sha256:9c7f200c07e3d4a03e7249d2c16bf66a51120fb876aa2242cf31451412543289
ENV DEBIAN_FRONTEND=noninteractive

# Set by the builder (amd64 or arm64); plain `docker build` leaves it empty, meaning amd64.
ARG TARGETARCH

# Every download is checked against a SHA-256 recorded here when the version was pinned.
ARG AWSCLI_VERSION=2.40.3
ARG AWSCLI_SHA256_AMD64=4770c06c4ecfc8ba94b60d89e6c7018ab7ea2cf5341b1ef05f6f93c5d6e8b705
ARG AWSCLI_SHA256_ARM64=4c5f080c6c294eb0da77734c4520f5b5089cf45a4ee757ca34ddf7f9e512e66a
ARG SSM_PLUGIN_VERSION=1.2.896.0
ARG SSM_PLUGIN_SHA256_AMD64=53f51fcc67314a4bf85888a38a3967cd41f8d0f28a60a9469a63acf935ba713e
ARG SSM_PLUGIN_SHA256_ARM64=914eeca87b18b55356c58be197080f73742b3ca60d3823f0a45670dc9056aa9c
ARG MISE_VERSION=v2026.11.8
ARG MISE_SHA256_AMD64=d2d5a46f507bba772686e2c8f2316b3a4439dac49a37a30db5c0e7bb077c5431
ARG MISE_SHA256_ARM64=b36da3c4892380325d44dee3678ba618de191254d8a4aed8011ee66b28a6cbd7

# Basic command-line tools.
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl git jq less python3 unzip vim \
  && rm -rf /var/lib/apt/lists/*

# uid 1000 matches the usual host user, so mounted files stay writable. Ubuntu's image
# ships an `ubuntu` user with that uid, so it goes first.
RUN userdel -r ubuntu 2>/dev/null; useradd -ms /bin/bash -u 1000 dev

# Run the steps below with bash, stopping at the first command that fails.
SHELL ["/bin/bash", "-euo", "pipefail", "-c"]

# AWS CLI: pick the download for this CPU (ARM or Intel/AMD), check its SHA-256, install.
RUN if [ "${TARGETARCH:-amd64}" = arm64 ]; then arch=aarch64 sha="$AWSCLI_SHA256_ARM64"; \
    else arch=x86_64 sha="$AWSCLI_SHA256_AMD64"; fi; \
  curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-${arch}-${AWSCLI_VERSION}.zip" -o /tmp/awscli.zip; \
  echo "${sha}  /tmp/awscli.zip" | sha256sum -c -; \
  unzip -q /tmp/awscli.zip -d /tmp && /tmp/aws/install && rm -rf /tmp/aws /tmp/awscli.zip

# Session Manager plugin (for `aws ssm start-session`): same steps.
RUN if [ "${TARGETARCH:-amd64}" = arm64 ]; then dir=ubuntu_arm64 sha="$SSM_PLUGIN_SHA256_ARM64"; \
    else dir=ubuntu_64bit sha="$SSM_PLUGIN_SHA256_AMD64"; fi; \
  curl -fsSL "https://s3.amazonaws.com/session-manager-downloads/plugin/${SSM_PLUGIN_VERSION}/${dir}/session-manager-plugin.deb" -o /tmp/ssm.deb; \
  echo "${sha}  /tmp/ssm.deb" | sha256sum -c -; \
  dpkg -i /tmp/ssm.deb && rm -f /tmp/ssm.deb

# mise, which installs each repo's tools from its .tool-versions: same steps.
RUN if [ "${TARGETARCH:-amd64}" = arm64 ]; then arch=arm64 sha="$MISE_SHA256_ARM64"; \
    else arch=x64 sha="$MISE_SHA256_AMD64"; fi; \
  curl -fsSL "https://github.com/jdx/mise/releases/download/${MISE_VERSION}/mise-${MISE_VERSION}-linux-${arch}.tar.gz" -o /tmp/mise.tar.gz; \
  echo "${sha}  /tmp/mise.tar.gz" | sha256sum -c -; \
  tar -xzf /tmp/mise.tar.gz -C /tmp && install -m 0755 /tmp/mise/bin/mise /usr/local/bin/mise; \
  rm -rf /tmp/mise /tmp/mise.tar.gz

USER dev
ENV MISE_YES=1 \
    PATH=/home/dev/.local/share/mise/shims:$PATH

# Fail the build if either tool doesn't run.
RUN aws --version && mise --version

WORKDIR /workspace
CMD ["/bin/bash"]
