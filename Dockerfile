FROM mambaorg/micromamba:0.25.1-bullseye-slim

COPY prompt.sh /tmp/prompt.sh
RUN cat /tmp/prompt.sh >> $HOME/.bashrc

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
