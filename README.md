# docker-scrna

This repo contains the `Dockerfile` and `conda` environment specifications to enable rapid single-cell RNA-seq analysis.

| image | # of packages | use case |
|---|---|---|
|full-<version>| 702 | start to finish processing of cellranger count matrices, including normalization w/ `scran` and analysis w/ `scanpy` |
|minimal-<version> | 213 | quick and dirty image for analyzing pre-processed single cell data w/ `scanpy`

## Usage

```bash
docker run --rm -it -v $PWD:/data daylinmorgan/scrna:full-<version>
```

You can run these images locally using the included recipe `run` or see the included [`docker-compose`](./docker-compose.yml).

## Updating the Image Specifications

Before updating or building images the local dev environment should be setup.

```bash
make bootstarp
mamba activate ./env
```

Direct dependencies should be pinned in the associated `spec/<env>.yml`.
This environment `yaml` will be used by `conda-lock`
to generate the necessary explicit package list to pass to docker.

You can check for new versions of packages using the included script.

```bash
./get-versions.py --spec specs/full.yml # optionally --dump to output a new yaml with max versions
```

*NOTE*: This is only searching the `conda` package channels for the most recent versions. Ultimately
`conda-lock` should resolve them and catch conflicts.

## Building the Images

Docker images are built with `make`.
The build system is controlled by a few parameters defined in the included `Makefile`.

You can view these and the available commands by running either `make` or `make help`.

The version is preferentially set using `git` tags/commit info, but may be overridden.

To build the default image (full):

```bash
make build # or make b
```

You can control which image is built in 2 different ways:
```bash
TAG=minimal make build
# OR
make build-minimal
```
This will build and image tagged: daylinmorgan/scrna:minimal-<version>

*NOTE*: aliases work here as well i.e. `make b-minimal`.

## Why no latest tag?

These images are designed for reproducible science. A latest tag is not informative or stable.

## TODO

- [ ] offload build/push to Github Actions