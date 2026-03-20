FROM debian:stable-slim

ARG USERNAME=devuser
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    locales sudo ca-certificates curl \
    && rm -rf /var/lib/apt/lists/* \
    && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && locale-gen \
    && useradd -m -U ${USERNAME} \
    && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/${USERNAME} \
    && chmod 0440 /etc/sudoers.d/${USERNAME}

RUN apt-get update && apt-get install -y --no-install-recommends \
    ansible git \
    && rm -rf /var/lib/apt/lists/* \

USER ${USERNAME}
