#!/bin/bash
set -eux
binary_folder=$1

# Add the given folder to the system search path.
pushd $binary_folder
export PATH="$binary_folder:$PATH"
echo "$binary_folder has been added to the system search paths."
popd
