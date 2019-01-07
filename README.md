# tools

## Introduction ##

## Tutorial ##

### mupdatedb ###

This command is used to build the file information database for the **mlocate** command. mupdatedb take search paths as input argument and save file information in specified database. Use **-?** option to get detail information about to use mupdatedb

``` shell
mupdatedb -?
usage:
  mupdatedb [<paths> ... ] options

where options are:
  -?, -h, --help               display usage information
  -d, --database <database>    The file information database.
  -v, --verbose                Display verbose information
```

In the example below we will create the file information database and save it to **.database** file. This command can display verbose information if **--verbose** flag is given.

``` shell
mupdatedb src/ -d .database
```

### mlocate ###

Assume a file information database has been created then we can use it to quickly find files using different options. Below are frequently usage

**Build file information database**
This step is required before using the **mlocate** command

``` shell
mupdatedb src/ include/ lib/ doc/ -d .database -v
{
    "Input arguments": {
        "paths": [
            "doc",
            "include",
            "lib",
            "src"
        ],
        "database": ".database",
        "verbose": true
    }
}
Database size: 2545333
```

**Find file using simple pattern**

``` shell
mlocate -d .database Compression
src/folly/folly/compression/Compression.cpp
src/folly/folly/compression/Compression.h
src/folly/folly/compression/test/CompressionTest.cpp
src/rocksdb/java/src/test/java/org/rocksdb/CompressionOptionsTest.java
src/rocksdb/java/src/test/java/org/rocksdb/CompressionTypesTest.java
src/rocksdb/java/src/main/java/org/rocksdb/CompressionOptions.java
src/rocksdb/java/src/main/java/org/rocksdb/CompressionType.java
```

**Find all files using regular expression**

``` shell
mlocate -d .database 'Compression.*java$'
src/rocksdb/java/src/test/java/org/rocksdb/CompressionOptionsTest.java
src/rocksdb/java/src/test/java/org/rocksdb/CompressionTypesTest.java
src/rocksdb/java/src/main/java/org/rocksdb/CompressionOptions.java
src/rocksdb/java/src/main/java/org/rocksdb/CompressionType.java
```

**Find all files with .cpp and .h extensions**

``` shell
mlocate -d .database 'Compression[.](h|cpp)$'
src/folly/folly/compression/Compression.cpp
src/folly/folly/compression/Compression.h
```

### mfind ###
mfind is a alternative solution to GNU find command. This command is significantly faster and it also allows to do a lot more thing with the regular expression. Below are typical use cases for mfind.

**Find files in a given folder**

``` shell
mfind share/zmq/
share/zmq/AUTHORS.txt
share/zmq/COPYING.txt
share/zmq/COPYING.LESSER.txt
share/zmq/NEWS.txt
```

**Find files with given extensions**

``` shell
mfind share/zmq/ -e '[.](txt)$'
share/zmq/AUTHORS.txt
share/zmq/COPYING.txt
share/zmq/COPYING.LESSER.txt
share/zmq/NEWS.txt
```

**Find files using specified pattern**

``` shell
mfind src/ -e 'Compression'
src/folly/folly/compression/Compression.cpp
src/folly/folly/compression/Compression.h
src/folly/folly/compression/test/CompressionTest.cpp
src/rocksdb/java/src/test/java/org/rocksdb/CompressionOptionsTest.java
src/rocksdb/java/src/test/java/org/rocksdb/CompressionTypesTest.java
src/rocksdb/java/src/main/java/org/rocksdb/CompressionOptions.java
src/rocksdb/java/src/main/java/org/rocksdb/CompressionType.java
```

**Using more complicated pattern**
``` shell
mfind src/ -e 'Compression.*Test'
src/folly/folly/compression/test/CompressionTest.cpp
src/rocksdb/java/src/test/java/org/rocksdb/CompressionOptionsTest.java
src/rocksdb/java/src/test/java/org/rocksdb/CompressionTypesTest.java
```

**Ignore cases**

``` shell
mfind src/ -e 'Compression.*Test'
src/folly/folly/compression/test/CompressionTest.cpp
src/rocksdb/java/src/test/java/org/rocksdb/CompressionOptionsTest.java
src/rocksdb/java/src/test/java/org/rocksdb/CompressionTypesTest.java
```

**Using inverse match feature i.e find files that do not match specified pattern**

``` shell
mfind share/zmq/ --inverse-match -e 'COPYING'
share/zmq/AUTHORS.txt
share/zmq/NEWS.txt
```

### fgrep ###

**fgrep** is a very fast grep like command. Out benchmark shows that **fgrep** can be 2x faster than grep for tasks with moderate or complicated regular expression patterns and it at least as fast as that of grep for simple tasks.

**fgrep help**

``` shell
./fgrep --help
usage:
  fgrep [<paths> ... ] options

where options are:
  -?, -h, --help                  display usage information
  -v, --verbose                   Display verbose information
  --exact-match                   Use exact matching algorithms.
  --inverse-match                 Print lines that do not match given
                                  pattern.
  -i, --ignore-case               Ignore case
  --stream                        Get data from the input pipe/stream.
  --mmap                          Get data from the input pipe/stream.
  -c, --color                     Print out color text.
  -l, --linenum                   Display line number.
  -s, --stdin                     Read data from the STDIN.
  -e, --pattern <pattern>         Search pattern.
  -e, --pattern <path_pattern>    Search pattern.
```

**Search for a pattern from a file**

``` shell
fgrep hello 3200.txt
the rich argosies of Venetian commerce--with Othellos and Desdemonas,
Phellow's Bosom Phriend.'  The funniest thing!--I've read it four times,
himself to be Othello or some such character, and imagining that the
hello-girl along ten thousand miles of wire could teach gentleness,
certain hello-girl of West Hartford, and I wished she could see
hello to them just as I would to anybody. I didn't mean to be
--clang----and, by that time you're--hello, what's all this excitement
a scene or two in "Othello."
```

**Grep for text from an input stream**

``` shell
cat 3200.txt | fgrep --stdin hello
the rich argosies of Venetian commerce--with Othellos and Desdemonas,
Phellow's Bosom Phriend.'  The funniest thing!--I've read it four times,
himself to be Othello or some such character, and imagining that the
hello-girl along ten thousand miles of wire could teach gentleness,
certain hello-girl of West Hartford, and I wished she could see
hello to them just as I would to anybody. I didn't mean to be
--clang----and, by that time you're--hello, what's all this excitement
a scene or two in "Othello."
```
