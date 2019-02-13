# tools

## Introduction ##

## Tutorial ##

### mupdatedb ###

This command is used to build the file information database for the **mlocate** command. **mupdatedb** takes search paths as input argument and save all file information in specified database path. Use **-?** option to get detail information about mupdatedb's supported options.

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

Assume a file information database has been created then we can use it to quickly find/locate files using different options. Our benchmark results shows that mlocate at least 2x faster than that of locate for normal use cases. Below are practical examples

**Build file information database**

This step is required before using the **mlocate** command

``` shell
hdang@macos ~/w/t/D/x/1/avx2> ./mupdatedb $HOME/working/ -v
{
    "Input arguments": {
        "paths": [
            "/Users/hdang/working"
        ],
        "database": ".database",
        "verbose": true
    }
}
buffer size: 19087485
```

**Find files using a simple search pattern**

``` shell
hdang@macos ~/w/t/D/x/1/avx2> time ./mlocate 'CompressionTest'
/Users/hdang/working/worker-3p/src/hazelcast/hazelcast/src/test/java/com/hazelcast/internal/serialization/impl/CompressionTest.java
/Users/hdang/working/worker-3p/src/vert.x/src/test/java/io/vertx/test/core/Http2CompressionTest.java
/Users/hdang/working/worker-3p/src/vert.x/src/test/java/io/vertx/test/core/HttpCompressionTest.java
/Users/hdang/working/3p/src/zapcc/unittests/Support/CompressionTest.cpp
        0.05 real         0.02 user         0.00 sys
```

**Find files using a regular expression pattern**

``` shell
hdang@macos ~/w/t/D/x/1/avx2> time ./mlocate 'rocksdb.*Compression'
/Users/hdang/working/backup/projects/projects/others/coverage/3p/rocksdb/java/src/main/java/org/rocksdb/CompressionOptions.java
/Users/hdang/working/backup/projects/projects/others/coverage/3p/rocksdb/java/src/main/java/org/rocksdb/CompressionType.java
/Users/hdang/working/backup/projects/projects/others/coverage/3p/rocksdb/java/src/test/java/org/rocksdb/CompressionTypesTest.java
/Users/hdang/working/backup/projects/projects/others/coverage/3p/rocksdb/java/src/test/java/org/rocksdb/CompressionOptionsTest.java
/Users/hdang/working/3p/src/rocksdb/java/src/main/java/org/rocksdb/CompressionOptions.java
/Users/hdang/working/3p/src/rocksdb/java/src/main/java/org/rocksdb/CompressionType.java
/Users/hdang/working/3p/src/rocksdb/java/src/test/java/org/rocksdb/CompressionTypesTest.java
/Users/hdang/working/3p/src/rocksdb/java/src/test/java/org/rocksdb/CompressionOptionsTest.java
        0.07 real         0.04 user         0.01 sys
```

**Find files with .cpp and .h extensions**

``` shell
hdang@macos ~/w/t/D/x/1/avx2> time ./mlocate 'Compression.*[cpp|hpp]$'
/Users/hdang/working/3p/src/zapcc/lib/Support/Compression.cpp
/Users/hdang/working/3p/src/zapcc/unittests/Support/CompressionTest.cpp
/Users/hdang/working/3p/src/zapcc/include/llvm/Support/Compression.h
/Users/hdang/working/3p/include/llvm/Support/Compression.h
        0.08 real         0.04 user         0.01 sys
```

### mfind ###
**mfind** is an alternative solution to [GNU find](https://www.gnu.org/software/findutils/manual/html_mono/find.html) command. This command is significantly faster than GNU find (see benchmark results below) and it also support extended regular exprssion syntax by default. Below are typical use cases for mfind.

**Find files in a given folder**

``` shell
hdang@macos ~/w/t/D/x/1/avx2> ./mfind ./
./source2tests
./mlocate
./codesearch
./mupdatedb
./.database
./mfind
./mwc
./fgrep
```

**Find files using regular expression**

``` shell
hdang@macos ~/w/t/D/x/1/avx2> time mfind ~/working/3p/src/boost/ -e 'coroutine(\w_)*.hpp$'
/Users/hdang/working/3p/src/boost/libs/asio/include/boost/asio/coroutine.hpp
/Users/hdang/working/3p/src/boost/libs/coroutine2/include/boost/coroutine2/coroutine.hpp
/Users/hdang/working/3p/src/boost/libs/coroutine2/include/boost/coroutine2/detail/pull_coroutine.hpp
/Users/hdang/working/3p/src/boost/libs/coroutine2/include/boost/coroutine2/detail/coroutine.hpp
/Users/hdang/working/3p/src/boost/libs/coroutine2/include/boost/coroutine2/detail/push_coroutine.hpp
/Users/hdang/working/3p/src/boost/libs/coroutine/include/boost/coroutine/asymmetric_coroutine.hpp
/Users/hdang/working/3p/src/boost/libs/coroutine/include/boost/coroutine/coroutine.hpp
/Users/hdang/working/3p/src/boost/libs/coroutine/include/boost/coroutine/symmetric_coroutine.hpp
        0.43 real         0.06 user         0.33 sys
```

**Ignore cases**

``` shell
hdang@macos ~/w/t/D/x/1/avx2> time mfind ~/working/3p/src/boost/ -e 'Coroutine(\w_)*.hpp$' -i
/Users/hdang/working/3p/src/boost/libs/asio/include/boost/asio/coroutine.hpp
/Users/hdang/working/3p/src/boost/libs/coroutine2/include/boost/coroutine2/coroutine.hpp
/Users/hdang/working/3p/src/boost/libs/coroutine2/include/boost/coroutine2/detail/pull_coroutine.hpp
/Users/hdang/working/3p/src/boost/libs/coroutine2/include/boost/coroutine2/detail/coroutine.hpp
/Users/hdang/working/3p/src/boost/libs/coroutine2/include/boost/coroutine2/detail/push_coroutine.hpp
/Users/hdang/working/3p/src/boost/libs/coroutine/include/boost/coroutine/asymmetric_coroutine.hpp
/Users/hdang/working/3p/src/boost/libs/coroutine/include/boost/coroutine/coroutine.hpp
/Users/hdang/working/3p/src/boost/libs/coroutine/include/boost/coroutine/symmetric_coroutine.hpp
        0.45 real         0.06 user         0.35 sys
```

**Using inverse match feature i.e find files that do not match specified pattern**

``` shell
hdang@macos ~/w/t/D/x/1/avx2> ./mfind --inverse-match find ./
./source2tests
./mlocate
./codesearch
./mupdatedb
./.database
./mfind
./mwc
./fgrep
```

### fgrep ###

**fgrep** is a very fast grep like command. Our performance benchmark results show that **fgrep** can be 2x or more faster than [grep](https://www.gnu.org/software/grep/) for tasks with moderate or complicated regular expression patterns. fgrep's performance is comparable to that [ripgrep](https://github.com/BurntSushi/ripgrep) for small or medium files and it can be 2x faster than [ripgrep](https://github.com/BurntSushi/ripgrep) for very large files i.e several GBytes log files.

**fgrep help messages**

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
hdang@macos ~/w/t/D/x/1/avx2> ./fgrep hello ~/working/ioutils/benchmark/3200.txt
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
hdang@macos ~/w/t/D/x/1/avx2> cat ~/working/ioutils/benchmark/3200.txt | ./fgrep --stdin hello
the rich argosies of Venetian commerce--with Othellos and Desdemonas,
Phellow's Bosom Phriend.'  The funniest thing!--I've read it four times,
himself to be Othello or some such character, and imagining that the
hello-girl along ten thousand miles of wire could teach gentleness,
certain hello-girl of West Hartford, and I wished she could see
hello to them just as I would to anybody. I didn't mean to be
--clang----and, by that time you're--hello, what's all this excitement
a scene or two in "Othello."
```

**Grep for lines that do not match given patterns**

``` shell
fgrep '(\||-|=)' output.log --inverse-match
crossed thus +.'  'Henry keeps well, but broods over our troubles more
```

### codesearch command ###

codesearch command can be used to search for lines from indexed database. Note that the indexed database is generated using builddb command. Before using code search we do need to generate the database first then use it to search for our desired lines. Our performance benchmark results show that code search is faster than aglimpse and comparable to Google codesearch.

**Generate the indexed data for RocksDB codebase**

``` shell
hdang@macos ~/w/t/D/x/1/avx2> time ./builddb -d foo ~/working/3p/src/rocksdb/ -e '[.](cpp|hpp|hh|cc|h|c|txt|md)$'
Number of files: 808
Read bytes: 11114650
        0.24 real         0.05 user         0.15 sys
```

**Search for the usage of zstd**

``` shell
hdang@macos
~/w/t/D/x/1/avx2> time ./codesearch -d foo zstd
/Users/hdang/working/3p/src/rocksdb//CMakeLists.txt:92:  option(WITH_ZSTD "build with zstd" OFF)
/Users/hdang/working/3p/src/rocksdb//CMakeLists.txt:94:    find_package(zstd REQUIRED)
/Users/hdang/working/3p/src/rocksdb//HISTORY.md:230:* Allow preset compression dictionary for improved compression of block-based tables. This is supported for zlib, zstd, and lz4. The compression dictionary's size is configurable via CompressionOptions::max_dict_bytes.
/Users/hdang/working/3p/src/rocksdb//INSTALL.md:38:  - [zstandard](http://www.zstd.net) - Fast real-time compression
/Users/hdang/working/3p/src/rocksdb//INSTALL.md:58:    * Install zstandard: `sudo apt-get install libzstd-dev`.
/Users/hdang/working/3p/src/rocksdb//INSTALL.md:96:             wget https://github.com/facebook/zstd/archive/v1.1.3.tar.gz
/Users/hdang/working/3p/src/rocksdb//INSTALL.md:97:             mv v1.1.3.tar.gz zstd-1.1.3.tar.gz
/Users/hdang/working/3p/src/rocksdb//INSTALL.md:98:             tar zxvf zstd-1.1.3.tar.gz
/Users/hdang/working/3p/src/rocksdb//INSTALL.md:99:             cd zstd-1.1.3
/Users/hdang/working/3p/src/rocksdb//include/rocksdb/c.h:926:  rocksdb_zstd_compression = 7
/Users/hdang/working/3p/src/rocksdb//table/format.cc:557:        static char zstd_corrupt_msg[] =
/Users/hdang/working/3p/src/rocksdb//table/format.cc:559:        return Status::Corruption(zstd_corrupt_msg);
/Users/hdang/working/3p/src/rocksdb//tools/db_bench_tool.cc:694:  else if (!strcasecmp(ctype, "zstd"))
/Users/hdang/working/3p/src/rocksdb//tools/db_stress.cc:435:  else if (!strcasecmp(ctype, "zstd"))
/Users/hdang/working/3p/src/rocksdb//tools/ldb_cmd.cc:557:    } else if (comp == "zstd") {
/Users/hdang/working/3p/src/rocksdb//tools/ldb_tool.cc:52:             "=<no|snappy|zlib|bzip2|lz4|lz4hc|xpress|zstd>\n");
/Users/hdang/working/3p/src/rocksdb//util/compression.h:37:#include <zstd.h>
        0.11 real         0.05 user         0.02 sys
```

## source2tests command ##

This command will output the list of tests given the search pattern and path constraints. It works well with any language given users know hoiw the pattern of their tests. Below is the simple example, which find the list of RocksDB C++ test that interract with zstd library.

**Get the list of tests that use zstd**

``` shell
hdang@macos ~/w/t/D/x/1/avx2> time ./source2tests  -d foo 'zstd' -p '[.](cpp|cc)$'
/Users/hdang/working/3p/src/rocksdb//table/format.cc
/Users/hdang/working/3p/src/rocksdb//tools/db_bench_tool.cc
/Users/hdang/working/3p/src/rocksdb//tools/db_stress.cc
/Users/hdang/working/3p/src/rocksdb//tools/ldb_cmd.cc
/Users/hdang/working/3p/src/rocksdb//tools/ldb_tool.cc
```

## Benchmark results ##

### MacOS Darwin Kernel Version 18.2.0 ###

#### fgrep ####

``` shell
macos:benchmark hdang$ ./all_tests
Celero
Timer resolution: 0.001000 us
-----------------------------------------------------------------------------------------------------------------------------------------------
     Group      |   Experiment    |   Prob. Space   |     Samples     |   Iterations    |    Baseline     |  us/Iteration   | Iterations/sec  |
-----------------------------------------------------------------------------------------------------------------------------------------------
mark_twain      | grep            |               0 |               5 |               1 |         1.00000 |   1243421.00000 |            0.80 |
mark_twain      | ag              |               0 |               5 |               1 |         1.88157 |   2339587.00000 |            0.43 |
mark_twain      | ripgrep         |               0 |               5 |               1 |         0.69388 |    862789.00000 |            1.16 |
mark_twain      | fgrep_mmap      |               0 |               5 |               1 |         0.59429 |    738955.00000 |            1.35 |
mark_twain      | fgrep_default   |               0 |               5 |               1 |         0.52595 |    653983.00000 |            1.53 |
Complete.
```

#### mfind ####

``` shell
./mfind -g boost
Celero
Timer resolution: 0.001000 us
-----------------------------------------------------------------------------------------------------------------------------------------------
     Group      |   Experiment    |   Prob. Space   |     Samples     |   Iterations    |    Baseline     |  us/Iteration   | Iterations/sec  |
-----------------------------------------------------------------------------------------------------------------------------------------------
boost           | gnu_find        |               0 |              10 |               1 |         1.00000 |   1013653.00000 |            0.99 |
boost           | fd              |               0 |              10 |               1 |         1.02080 |   1034736.00000 |            0.97 |
boost           | mfind_to_consol |               0 |              10 |               1 |         0.45755 |    463798.00000 |            2.16 |
Complete.
```

``` shell
./mfind -g boost_regex
Celero
Timer resolution: 0.001000 us
-----------------------------------------------------------------------------------------------------------------------------------------------
     Group      |   Experiment    |   Prob. Space   |     Samples     |   Iterations    |    Baseline     |  us/Iteration   | Iterations/sec  |
-----------------------------------------------------------------------------------------------------------------------------------------------
boost_regex     | gnu_find        |               0 |              10 |               1 |         1.00000 |   1001279.00000 |            1.00 |
boost_regex     | fd              |               0 |              10 |               1 |         0.91047 |    911631.00000 |            1.10 |
boost_regex     | mfind_to_consol |               0 |              10 |               1 |         0.46879 |    469385.00000 |            2.13 |
Complete.
```

#### mlocate ####

## FAQs ##

### License ###

Our tools is only free for **non-commercial or personal usage**. Please contact us at **hungptit at gmail dot com** for detail information. 
