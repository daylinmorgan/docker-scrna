#!/usr/bin/env python3

import sys
from pathlib import Path

import jinja2

TAGS = ["minimal", "full"]


def size_lock(tag):
    with Path(f"locks/{tag}.lock").open("r") as f:
        return len(f.read().split("@EXPLICIT")[1].strip().splitlines())


def main():

    version = sys.argv[1]
    template_file = sys.argv[2]

    pkgs = {tag: size_lock(tag) for tag in TAGS}

    templateLoader = jinja2.FileSystemLoader(
        searchpath=Path(__file__).parent.parent / "tmpl"
    )
    templateEnv = jinja2.Environment(loader=templateLoader)
    template = templateEnv.get_template(template_file)
    outputText = template.render(version=version, pkgs=pkgs)

    print(outputText)


if __name__ == "__main__":
    main()
