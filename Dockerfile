FROM mambaorg/micromamba:git-476701e-bullseye-slim

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
