#!/bin/bash
working_dir="${PWD}/../"
echo $working_dir
set -eux

build_option=${1:-"avx2"}

install_binaries() {
    option=$1
    if [ $option == "sse2" ]; then
        cmake_options="-DUSE_AVX2=FALSE"
    else
        cmake_options="-DUSE_AVX2=TRUE"
    fi
    echo $option
    echo $cmake_options

    # Install fgrep
    pushd "$working_dir/fastgrep/commands"
    cmake ./ "$cmake_options" > /dev/null
    make clean > /dev/null
    make -j5 install > /dev/null
    popd

    # Install fast-locate, fast-find, fast-updatedb, and fast-wc
    pushd "$working_dir/ioutils/commands"
    cmake ./ "$cmake_options" > /dev/null
    make clean > /dev/null 
    make -j5 install > /dev/null
    popd

    # Install codesearch and source2tests
    pushd "$working_dir/codesearch/commands"
    cmake ./ "$cmake_options" > /dev/null
    make clean > /dev/null 
    make -j5 install > /dev/null
    popd
}

# Copy binaries to the destination
copy_binaries() {
    build_mode=$1
    platform=`uname -s`
    architect=`uname -m`
    release=`uname -r`
    src_dir="$HOME/bin"
    dest_dir="$platform/$architect/$release/$build_mode"
    mkdir -p $dest_dir
    binaries="fast-wc fgrep fast-locate fast-updatedb fast-find builddb codesearch source2tests "
    for cmd in $binaries; do
        echo "Copying $cmd ..."
        cp -f "$src_dir/$cmd" "$dest_dir/$cmd"
    done
}

# Build and copy binaries to distributed folder.
install_binaries $build_option
copy_binaries $build_option

set +x
