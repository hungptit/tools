#!/bin/bash
src=$1

data1="find.log"
data2="fast-find.log"
data3="fd.log"

set +x

# Find all files in a given folder using GNU find.
echo "Find all files using GNU find"
/usr/bin/time find $src | sort -s > $data1

# Find all files using fast-find
echo "Find all files using fast-find"
/usr/bin/time fast-find $src --donot-ignore-git | sort -s > $data2

# Find all files using fd
echo "Find all files using fd"
/usr/bin/time fd . $src -H --no-ignore | sort -s > $data3

# Verify the output of fast-find
echo "\n==== Verify the output of fast-find ===="
diff $data1 $data2

echo "\n==== Verify the output of fd ===="
# Verify the output of fd
diff $data1 $data3

set -x
