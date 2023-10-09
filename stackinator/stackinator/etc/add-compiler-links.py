#!/usr/bin/env python3

# Hard code the path to the system python3 on HPE Cray EX systems.

import argparse
import os

import yaml


# parse compilers.yaml file.
# return a list with the compiler descriptions from the yaml file.
def load_compilers_yaml(path):
    with open(path, "r") as file:
        data = yaml.safe_load(file)
    compilers = [c["compiler"] for c in data["compilers"]]
    return compilers


def parse_export(line):
    s = line.replace("=", " ").split()
    var = s[1]
    paths = None
    if len(s) > 2:
        paths = s[2].rstrip(";").split(":")
    return {"variable": var, "paths": paths}


def split_line(line):
    return line.strip().rstrip(";").replace("=", " ").split()


def is_export(parts):
    return len(parts) > 1 and parts[0] == "export"


def is_alias(parts):
    return len(parts) > 0 and parts[0] == "alias"


# Returns True if the given path is a descendant of prefix, False otherwise.
def has_prefix(path, prefix):
    prefix = os.path.realpath(prefix)
    path = os.path.realpath(path)
    return os.path.commonprefix([path, prefix]) == prefix


parser = argparse.ArgumentParser()
parser.add_argument("compiler_path", help="Path to the compilers.yaml file")
parser.add_argument("activate_path", help="Path to the activate script to configure")
parser.add_argument("build_path", help="Path where the build is performed")
args = parser.parse_args()

if not os.path.exists(args.compiler_path):
    print(f"error - compiler file '{args.compiler_path}' does not exist.")
    exit(2)

if not os.path.exists(args.activate_path):
    print(f"error - activation file '{args.activate_path}' does not exist.")
    exit(2)

if not os.path.exists(args.build_path):
    print(f"error - build path '{args.build_path}' does not exist.")
    exit(2)

compilers = load_compilers_yaml(args.compiler_path)

paths = []
for c in compilers:
    local_paths = set([os.path.dirname(v) for k, v in c["paths"].items()])
    paths += local_paths
    print(f'adding compiler {c["spec"]} -> {[p for p in local_paths]}')

# find unique paths and concatenate them
pathstring = ":".join(set(paths))

# Parse the spack env activation script line by line.
# Remove spack-specific environment variables and references the build path.

# NOTE: the activation script generated by spack effectively clears PATH, CPATH,
# etc. This may or may not be surprising for users, and we may have to append
# :$PATH, :$CPATH, etc.

lines = []
with open(args.activate_path) as fid:
    for line in fid:
        parts = split_line(line)

        # drop any aliases (bash functions created by spack)
        if is_alias(parts):
            pass
        elif is_export(parts):
            export = parse_export(line)

            # parse PATH to remove references to the build directory
            if export["variable"] == "PATH":
                paths = [
                    p for p in export["paths"] if not has_prefix(p, args.build_path)
                ]
                lines.append(f"export PATH={':'.join(paths)};\n")

            # drop the SPACK_ENV variable
            elif export["variable"] == "SPACK_ENV":
                pass

            else:
                lines.append(line.strip() + "\n")
        else:
            lines.append(line.strip() + "\n")

# Prepend the compiler paths to PATH
lines.append("# compiler paths added by stackinator\n")
lines.append(f"export PATH={pathstring}:$PATH;\n")

# Write a modified version of the activation script.
with open(args.activate_path, "w") as fid:
    fid.writelines(lines)
