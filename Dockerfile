FROM mambaorg/micromamba:git-476701e-bullseye-slim
ARG QUARTO_VERSION=1.1.251
USER root
RUN apt-get update && apt-get install -y curl && curl -fsSL https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-linux-amd64.deb -o quarto.deb && \
  dpkg -i quarto.deb
USER mambauser

COPY prompt.sh /tmp/prompt.sh
RUN cat /tmp/prompt.sh >> /home/mambauser/.bashrc

ARG LOCKFILE
COPY $LOCKFILE tmp/prod.lock

RUN micromamba \
  install --name base \
  --yes \
  -f tmp/prod.lock \
  && \
  micromamba clean --all --force-pkgs-dirs --yes

ARG MAMBA_DOCKERFILE_ACTIVATE=1  # (otherwise python will not be found)
WORKDIR /data

ENTRYPOINT ["/usr/local/bin/_entrypoint.sh"]

CMD ["bash"]
