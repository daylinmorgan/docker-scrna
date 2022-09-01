#!/usr/bin/env bash

VERSION=$(git describe --tags --always --dirty | sed s'/dirty/dev/')
FULL_PKGS=$(tail -n +5 locks/full.lock | wc -l)
MINIMAL_PKGS=$(tail -n +5 locks/minimal.lock | wc -l)

cat << EOF
# docker-scrna

This repo contains the \`Dockerfile\` and \`conda\` environment specifications to enable rapid single-cell RNA-seq analysis.

| image | # of packages | use case |
|---|---|---|
|full-${VERSION} | ${FULL_PKGS} | start to finish processing of cellranger count matrices, including normalization w/ \`scran\` and analysis w/ \`scanpy\` |
|minimal-${VERSION} | ${MINIMAL_PKGS} | quick and dirty image for analyzing pre-processed single cell data w/ \`scanpy\`

## Usage

\`\`\`bash
docker run --rm -it -v \$PWD:/data daylinmorgan/scrna:full-${VERSION}
\`\`\`

See [repo](https://github.com/daylinmorgan/docker-scrna) for more info.

EOF
