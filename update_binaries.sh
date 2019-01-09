#!/bin/bash
working_dir="${PWD}/../"
echo $working_dir
set +x

# Install fgrep
pushd "$working_dir/fastgrep/commands"
make clean > /dev/null
make -j5 install > /dev/null
popd

# Install mlocate, mfind, mupdatedb, and mwc
pushd "$working_dir/ioutils/commands"
make clean > /dev/null 
make -j5 install > /dev/null
popd

# Install codesearch and source2tests
pushd "$working_dir/codesearch/commands"
make clean > /dev/null 
make -j5 install > /dev/null
popd

# Copy binaries to the destination
platform=`uname -s`
architect=`uname -m`
release=`uname -r`

src_dir="$HOME/bin"
dest_dir="$platform/$architect/$release"
mkdir -p $dest_dir
binaries="fgrep mlocate mupdatedb mfind codesearch source2tests "
for cmd in $binaries; do
    echo "Copying $cmd ..."
    cp -f "$src_dir/$cmd" "$dest_dir/$cmd"
done

set -x
