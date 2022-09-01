#!/usr/bin/env python3

import argparse
import os
import re
import sys

from mamba import repoquery
from ruamel.yaml import YAML

yaml = YAML()
yaml.indent(mapping=2, sequence=4, offset=2)

if sys.stdout.isatty():
    BOLD, YELLOW, GREEN, RED, NC = (f"\033[{x}m" for x in (1, 33, 32, 31, 0))
else:
    BOLD, YELLOW, GREEN, RED, NC = ("",) * 5


def get_name(pkg_str):
    return re.split("=|<|>", pkg_str, maxsplit=1)[0].strip()


# basically just to hide mamba outputs to stderr
def suppress_stdout_stderr(func):
    def wrapper(*a, **ka):
        with open(os.devnull, "w") as devnull:
            orig_stdout_fno = os.dup(sys.stdout.fileno())
            os.dup2(devnull.fileno(), 1)
            # suppress stderr
            orig_stderr_fno = os.dup(sys.stderr.fileno())
            os.dup2(devnull.fileno(), 2)
            # get suppressed functions output
            out = func(*a, **ka)
            os.dup2(orig_stdout_fno, 1)  # restore stdout
            os.dup2(orig_stderr_fno, 2)  # restore stderr
            return out

    return wrapper


@suppress_stdout_stderr
def fetch_most_recent_version(dep, pool):
    return repoquery.search(dep, pool=pool)


def get_recent_version(pkg, pool):
    search_result = fetch_most_recent_version(pkg, pool)
    try:
        return search_result["result"]["pkgs"][0]["version"]
    except IndexError:
        print(f"{RED}ERROR{NC}: failed to fetch version for {pkg}")
        sys.exit(1)


@suppress_stdout_stderr
def get_pool(channels):
    return repoquery.create_pool(
        channels=channels, platform="linux-64", installed=False
    )


def print_versions(deps):
    name_length = max((len(name) for name in deps))
    lengths = (
        max((len(name) for name in deps)),
        max((len(info["spec"]) for info in deps.values())),
        max((len(info["version"]) for info in deps.values())),
    )

    h = "{RED}{3:<{0}}{NC} | {RED}{4:<{1}}{NC} | {RED}{5:<{2}}{NC}".format(
        *lengths, "name", "spec", "latest", RED=RED, NC=NC
    )
    print(h)
    print("-" * (len(h) - len(RED * 3 + NC * 3)))
    for name, info in deps.items():
        s = "{BOLD}{3:<{0}}{NC} | {YELLOW}{4:<{1}}{NC} | {GREEN}{5:<{2}}{NC}".format(
            *lengths,
            name,
            info["spec"],
            info["version"],
            BOLD=BOLD,
            GREEN=GREEN,
            YELLOW=YELLOW,
            NC=NC,
        )
        print(s)


def clear_stderr():
    print("\033[K", file=sys.stderr, end="\r")


def get_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("--spec", help="environemnt yml spec", required=True)
    parser.add_argument("--dump", help="dump the spec as yml", action="store_true")

    return parser.parse_args()


def remove_comments(spec):
    comments = spec.ca.items.copy()
    for k in comments:
        del spec.ca.items[k]
    return spec


def main():
    args = get_args()

    with open(args.spec, "r") as f:
        spec = yaml.load(f)

    spec = remove_comments(spec)

    deps = {}
    for dep in spec["dependencies"]:
        deps[get_name(dep)] = {"spec": dep}

    print("Generating repoquery pool..", file=sys.stderr, end="\r")
    pool = get_pool(spec["channels"])
    clear_stderr()

    for pkg in deps:
        print(f"\033[Kfetching version: {BOLD}{pkg}{NC}", end="\r", file=sys.stderr)
        deps[pkg]["version"] = get_recent_version(pkg, pool)

    clear_stderr()

    if args.dump:
        spec["dependencies"] = [
            f"{pkg}={info['version']}" for pkg, info in deps.items()
        ]
        yaml.dump(spec, sys.stdout)
    else:
        print_versions(deps)


if __name__ == "__main__":
    main()
