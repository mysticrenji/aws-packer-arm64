FROM arm64v8/debian:buster-slim

ARG GITHUB_RUNNER_VERSION="2.276.1"
ARG DOCKER_CLI_VERSION="18.06.3-ce"
ENV DOWNLOAD_URL="https://download.docker.com/linux/static/edge/aarch64/docker-$DOCKER_CLI_VERSION.tgz"

ENV RUNNER_NAME "github-runner-arm64"
ENV GITHUB_PAT ""
ENV GITHUB_OWNER ""
ENV GITHUB_REPOSITORY ""
ENV RUNNER_WORKDIR "_work"
ENV TERRAFORM_VERSION "0.12.30"
ENV PACKER_VERSION "1.6.6"

RUN apt-get update \
    && apt-get install -y \
        curl \
        sudo \
        git \
        jq \
        unzip \
        wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && useradd -m github \
    && usermod -aG sudo github \
    && echo "%sudo ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER github
WORKDIR /home/github

RUN wget https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_arm64.zip && unzip packer_${PACKER_VERSION}_linux_arm64.zip \
    && sudo mv packer /usr/local/bin/

RUN wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_arm64.zip && unzip terraform_${TERRAFORM_VERSION}_linux_arm64.zip \
    && sudo mv terraform /usr/local/bin/
    
RUN curl -Ls https://github.com/actions/runner/releases/download/v${GITHUB_RUNNER_VERSION}/actions-runner-linux-arm64-${GITHUB_RUNNER_VERSION}.tar.gz | tar xz \
    && sudo ./bin/installdependencies.sh

RUN mkdir -p /tmp/docker/ && curl -Ls https://download.docker.com/linux/static/edge/aarch64/docker-${DOCKER_CLI_VERSION}.tgz | tar -xz -C /tmp/docker/ \
    && sudo mv /tmp/docker/docker/* /usr/local/bin/ \
    && rm  -rf /tmp/docker/

COPY --chown=github:github entrypoint.sh ./entrypoint.sh
RUN sudo chmod u+x ./entrypoint.sh

CMD ["/bin/bash"]
#ENTRYPOINT ["/home/github/entrypoint.sh"]
