# docker-scrna

This repo contains the `Dockerfile` and `conda` environment specifications to enable rapid single-cell RNA-seq analysis.

| image | # of packages | use case |
|---|---|---|
|full-{{version}}| {{pkgs['full']}} | start to finish processing of cellranger count matrices, including normalization w/ `scran` and analysis w/ `scanpy` |
|minimal-{{version}} | {{pkgs['minimal']}} | quick and dirty image for analyzing pre-processed single cell data w/ `scanpy`

Both images also contain the [`quarto-cli`](https://github.com/quarto-dev/quarto-cli).

## Usage

```bash
docker run --rm -it -v \$PWD:/data daylinmorgan/scrna:full-{{version}}
```

See [repo](https://github.com/daylinmorgan/docker-scrna) for more info.
