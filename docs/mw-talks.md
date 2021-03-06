class: center, middle
# Impossible Engineering Problems Often Aren't: How can I solve the source to test mapping challenge for large codebases

<!-- --- -->

<!-- # What do I do for the last two years? # -->

<!-- * My role is the mixture of a backend engineer and a SRE. We build, maintain, and operate a large distributed job excution system which processes more than 200 million requests per day. -->

<!-- * Write Perl, Bash, and Java code professionally. -->

<!-- * Write many tools (using C++) to speed up my workflow and the development workflow at AthenaHealth. -->

<!-- * Research about text searching algorithms. -->

---

# Why? #

--

* Trouble shooting and debugging

--

* Large refactoring tasks.

---

# Agenda #

--

* My [tools](https://github.com/hungptit/tools) are introduced in the topologically sorted order i.e mfind, fast-locate, fgrep, codesearch, and source2tests.

--

* Show benchmark results and analysis for each tool.

--

* Show some practical examples.

---
# fast-find #

--

* A fast replacement for [GNU find](https://www.gnu.org/software/findutils/)

--

* More flexible and offer some features that [GNU find](https://www.gnu.org/software/findutils/) does not.

---

# Benchmark results - non-git folder #

--
``` shell
ATH020224:benchmark hdang$ time find ~/working/3p/include/ | wc
   16813   16813 1200669

real    0m0.192s
user    0m0.021s
sys     0m0.177s
```

--
``` shell
ATH020224:benchmark hdang$ time fd . ~/working/3p/include/ | wc
   16812   16812 1183824

real    0m0.144s
user    0m0.168s
sys     0m0.677s
```

--
``` shell
ATH020224:benchmark hdang$ time ../commands/fast-find ~/working/3p/include/ | wc
   16812   16812 1183824

real    0m0.085s
user    0m0.018s
sys     0m0.067s
```

---

# Benchmark results - Big folder #

```shell
ATH020224:benchmark hdang$ ./fast-find -g big_folder
Celero
Timer resolution: 0.001000 us
-----------------------------------------------------------------------------------------------------------------------------------------------
     Group      |   Experiment    |   Prob. Space   |     Samples     |   Iterations    |    Baseline     |  us/Iteration   | Iterations/sec  |
-----------------------------------------------------------------------------------------------------------------------------------------------
big_folder      | gnu_find        |               0 |              20 |               1 |         1.00000 |    475287.00000 |            2.10 |
big_folder      | fd              |               0 |              20 |               1 |         1.09422 |    520067.00000 |            1.92 |
big_folder      | fast-find_default   |               0 |              20 |               1 |         0.53738 |    255410.00000 |            3.92 |
big_folder      | fast-find_dfs       |               0 |              20 |               1 |         0.52558 |    249803.00000 |            4.00 |
Complete.
```

---

# Benchmark results - Big folder with regex #

``` shell
ATH020224:benchmark hdang$ ./fast-find -g big_folder_regex
Celero
Timer resolution: 0.001000 us
-----------------------------------------------------------------------------------------------------------------------------------------------
     Group      |   Experiment    |   Prob. Space   |     Samples     |   Iterations    |    Baseline     |  us/Iteration   | Iterations/sec  |
-----------------------------------------------------------------------------------------------------------------------------------------------
big_folder_rege | gnu_find        |               0 |              20 |               1 |         1.00000 |    471865.00000 |            2.12 |
big_folder_rege | fd              |               0 |              20 |               1 |         0.96650 |    456056.00000 |            2.19 |
big_folder_rege | fast-find_default   |               0 |              20 |               1 |         0.54251 |    255993.00000 |            3.91 |
big_folder_rege | fast-find_dfs       |               0 |              20 |               1 |         0.53523 |    252554.00000 |            3.96 |
Complete.
```

---
# Why [fast-find](https://github.com/hungptit/ioutils) is so fast? #

--

* File traversal algorithms.

--

* Text search algorithms.

--

* All core algorithms are templatized so code are generated at compile time.

--
* Others

    * Cache line friendly algorithms.

    * The number of system calls is minimal.

    * All core algorithms are vectorized using SSE2/AVX2.

---

# BFS algorithm #

``` c++
template <typename Container> void bfs(Container &&p) {
  for (auto const &item : p) {
    int fd = ::open(item.data(), O_RDONLY);
    if (fd > -1)
      current.emplace_back(Path{fd, item});
  }

  // Search for files and folders using BFS traversal.
  int current_level = 0;
  while (!current.empty()) {
    next.clear();
    for (auto const &current_path : current) {
      visit(current_path);
    }
    ++current_level;
    if ((level > -1) && (current_level > level)) {
      break; // Stop if we have traverse to the desired depth.
    }
    std::swap(current, next);
  }
}
```

---

# DFS algorithm #

``` c++
template <typename Container> void dfs(Container &&p) {
  for (auto const &item : p) {
    int fd = ::open(item.data(), O_RDONLY);
    if (fd > -1)
      next.emplace_back(Path{fd, item});
  }

  // Search for files and folders using DFS traversal.
  while (!next.empty()) {
    auto parent = next.back();
    next.pop_back();
    visit(parent);
  }
}
```

---
# fast-locate #

--

* A compartible replacement for [GNU locate](https://www.gnu.org/software/findutils/).

--

* Can be 10x faster than [GNU locate](https://www.gnu.org/software/findutils/).

---

# Build file information database for my MacBook #

--

``` shell
ATH020224:/ hdang$ /usr/bin/time -lp gupdatedb --localpaths=/usr/ --localpaths=/Users/ --output="/Users/hdang/.locatedb"
real        35.37
user        10.82
sys         23.45
```

--

``` shell
ATH020224:/ hdang$ /usr/bin/time -lp fast-updatedb /usr/ /Users/ -d="/Users/hdang/.database"
real        56.82
user         2.99
sys         38.84
```

---

# GNU locate vs fast-locate #

--

``` shell
ATH020224:/ hdang$ time glocate -d ~/.locatedb --regex 'fmt.*string.h'
/Users/hdang/working/3p/include/fmt/string.h
/Users/hdang/working/3p/src/seastar/fmt/fmt/string.h
/Users/hdang/working/backup/projects/projects/code_coverage/include/fmt/string.h
/Users/hdang/working/backup/projects/projects/graph/3p/fmt/fmt/string.h
/Users/hdang/working/backup/projects/projects/graph/include/fmt/string.h
/Users/hdang/working/backup/projects/projects/others/coverage/3p/fmt/fmt/string.h
/Users/hdang/working/backup/projects/projects/tools/fmt/fmt/string.h

real    0m2.355s
user    0m2.287s
sys     0m0.039s
```

--

``` shell
ATH020224:/ hdang$ time fast-locate -d ~/.database 'fmt.*string.h'
/Users/hdang/working/backup/projects/projects/code_coverage/include/fmt/string.h
/Users/hdang/working/backup/projects/projects/others/coverage/3p/fmt/fmt/string.h
/Users/hdang/working/backup/projects/projects/graph/include/fmt/string.h
/Users/hdang/working/backup/projects/projects/graph/3p/fmt/fmt/string.h
/Users/hdang/working/backup/projects/projects/tools/fmt/fmt/string.h
/Users/hdang/working/3p/src/seastar/fmt/fmt/string.h
/Users/hdang/working/3p/include/fmt/string.h

real    0m0.217s
user    0m0.156s
sys     0m0.052s
```

???
* Got a lot of heated argument on the phone because some very senior software engineers do not believe it.
* This command might be several time faster than sblocate.

---

# Benchmark results using boost source code #

--
``` shell
ATH020224:benchmark hdang$ ./locate_benchmark
Celero
Timer resolution: 0.001000 us
-----------------------------------------------------------------------------------------------------------------------------------------------
     Group      |   Experiment    |   Prob. Space   |     Samples     |   Iterations    |    Baseline     |  us/Iteration   | Iterations/sec  |
-----------------------------------------------------------------------------------------------------------------------------------------------
regex           | gnu_locate      |               0 |              10 |               1 |         1.00000 |    649553.00000 |            1.54 |
regex           | fast-locate         |               0 |              10 |               1 |         0.06303 |     40943.00000 |           24.42 |
Complete.
```

---

# Why [fast-locate](https://github.com/hungptit/tools) is so fast? #

--

* [File reading algorithms](https://lemire.me/blog/2012/06/26/which-is-fastest-read-fread-ifstream-or-mmap/).

--

* [Text search algorithm](https://branchfree.org/2019/02/28/paper-hyperscan-a-fast-multi-pattern-regex-matcher-for-modern-cpus/).

--

* Optimized data structures for storing paths.

--

* All core algorithms are templatized so code are generated at compile time.

--

* Others

  * Minimum memory copy/allocation operations.

  * Cache line friendly algorithms and data structures.

  * All core algorithms are vectorized using SSE2/AVX2.

???


---

# fastgrep #

--

* fastgrep is created to address a real problem i.e log diving in production log with TB of text data.

--

* Build as a library so it can be reused in other projects.

--

* Need a portable text searching tool that works in any Linux system.

---

# Benchmark results - A single file #

``` shell
ATH020224:benchmark hdang$ ./all_tests -g mark_twain
Celero
Timer resolution: 0.001000 us
-----------------------------------------------------------------------------------------------------------------------------------------------
     Group      |   Experiment    |   Prob. Space   |     Samples     |   Iterations    |    Baseline     |  us/Iteration   | Iterations/sec  |
-----------------------------------------------------------------------------------------------------------------------------------------------
mark_twain      | grep            |               0 |               5 |               1 |         1.00000 |   1342977.00000 |            0.74 |
mark_twain      | ag              |               0 |               5 |               1 |         1.93253 |   2595342.00000 |            0.39 |
mark_twain      | ripgrep         |               0 |               5 |               1 |         0.79934 |   1073492.00000 |            0.93 |
mark_twain      | fgrep_mmap      |               0 |               5 |               1 |         0.65938 |    885527.00000 |            1.13 |
mark_twain      | fgrep_default   |               0 |               5 |               1 |         0.58866 |    790551.00000 |            1.26 |
Complete.
```

---
# Benchmark results - Multiple files #

``` shell
ATH020224:benchmark hdang$ ./all_tests -g boost_source
Celero
Timer resolution: 0.001000 us
-----------------------------------------------------------------------------------------------------------------------------------------------
     Group      |   Experiment    |   Prob. Space   |     Samples     |   Iterations    |    Baseline     |  us/Iteration   | Iterations/sec  |
-----------------------------------------------------------------------------------------------------------------------------------------------
boost_source    | grep            |               0 |               5 |               1 |         1.00000 |   1709024.00000 |            0.59 |
boost_source    | ag              |               0 |               5 |               1 |         1.12348 |   1920052.00000 |            0.52 |
boost_source    | ripgrep         |               0 |               5 |               1 |         0.98784 |   1688240.00000 |            0.59 |
boost_source    | fgrep           |               0 |               5 |               1 |         1.02164 |   1746005.00000 |            0.57 |
Complete.
```

---

# Benchmark results - Boost source code #

``` shell
/usr/bin/time -lp rg -Lun 'function_types.*hpp' -t cpp ../../3p/src/boost/ -c -n

/usr/bin/time -lp ~/bin/fgrep 'function_types.*hpp' ../../3p/src/boost/ -c -n -p '[.]hpp$'

/usr/bin/time -lp ggrep -Enr 'function_types.*hpp' ../../3p/src/boost/ --include=*.hpp
```

---
# Why fastgrep can be faster than GNU grep? #

--

* [File reading algorithms](https://lemire.me/blog/2012/06/26/which-is-fastest-read-fread-ifstream-or-mmap/).

--

* [Text search algorithm](https://branchfree.org/2019/02/28/paper-hyperscan-a-fast-multi-pattern-regex-matcher-for-modern-cpus/).

--

* [File traversal algorithms](https://github.com/hungptit/ioutils)

--

* Others

    * All core algorithms are templatized so code are generated at compile time.

    * Minimum memory copy.

    * Cache line friendly.

---
# codesearch #

--

* grep like tools are only good for a small or medium number of files. If you have a codebase with million lines of code then these tools do not work well.

--

* Allow users to quickly search for desired text pattern.

--

* Will significantly improve your development workflow especially you have to work with a lot of files everyday.

---

# Examples #

``` shell
ATH020224:3p hdang$ codesearch zstd.*round-trip -p 'tests.*(cpp|c)$'
src//zstd/tests/fuzz/block_round_trip.c:11: * This fuzz target performs a zstd round-trip test (compress & decompress),
src//zstd/tests/fuzz/simple_round_trip.c:11: * This fuzz target performs a zstd round-trip test (compress & decompress),
src//zstd/tests/fuzz/stream_round_trip.c:11: * This fuzz target performs a zstd round-trip test (compress & decompress),
src//zstd/tests/roundTripCrash.c:13:  performs a zstd round-trip test (compression - decompress)
```

---

# Can we use it? #

--

* codesearch is free. You can download *Nix versions of codesearch [here](https://github.com/hungptit/tools).

--

* There is a commercial version of codesearch/source2tests. This version

    * Supports REST interface.

    * Is faster than the free version.

    * Can be customized based on user requirements or specifications.

---
# source2tests #

--

* It is a impossible task for large codebases i.e million lines of code because of runtime and storage complexities.

--

* There is not any available solution yet.

---
# What are possible solutions? #

--

* **Use code coverage information i.e high-order analysis**

    - Runtime complexity: O(NM), where N is the number of source lines and M is the number of tests.
    - Space complexity: O(NM)
    - Confidence score: High

--

* **Use static text analysys i.e low-order analysis**

    - Runtime complexity: O(N)
    - Space complexity: O(N)
    - Confidence score: Medium

--

* **Use folder map i.e first or second order analysis.**

    - Runtime complexity: O(N)
    - Space complexity: O(1)
    - Confidence level: Low

---

# What does source2tests do? #

--

* Use the static text analysis to figure out tests need to run or execute.

--

* The current version only supports the first order analysis.

---

# Features #

--

* Work with any programming language.

--

* Has a basic command line interface.

---

# Examples - Find all zstd's tests #

--

``` shell
ATH020224:3p hdang$ source2tests zstd -p 'tests.*(cpp|c)$'
src//zstd/tests/checkTag.c
src//zstd/tests/decodecorpus.c
src//zstd/tests/fullbench.c
src//zstd/tests/fuzz/block_decompress.c
src//zstd/tests/fuzz/block_round_trip.c
src//zstd/tests/fuzz/simple_decompress.c
src//zstd/tests/fuzz/simple_round_trip.c
src//zstd/tests/fuzz/stream_decompress.c
src//zstd/tests/fuzz/stream_round_trip.c
src//zstd/tests/fuzz/zstd_helpers.c
src//zstd/tests/fuzzer.c
src//zstd/tests/invalidDictionaries.c
src//zstd/tests/legacy.c
src//zstd/tests/longmatch.c
src//zstd/tests/paramgrill.c
src//zstd/tests/roundTripCrash.c
src//zstd/tests/symbols.c
src//zstd/tests/zbufftest.c
src//zstd/tests/zstreamtest.c
```

---

# Run all Perl tests using special constraints #

--

* Run all Perl tests that

  * Use my module

  * Do not belong to me

--

``` shell
prove -j30 $(source2tests 'use WorkUnit' -p '[.](t)$' | fgrep --stdin --invert-match WorkUnit)
```

---

# C++ performance tips #

--

* [Measure, measure, and measure.](https://www.youtube.com/watch?v=Qq_WaiwzOtI)

--

* Minimize memory copy/write/allocation operations.

--

* Try to vectorize your code if possible.

--

* Use boost libraries with care for example boost hash function is [really slow](https://github.com/hungptit/clhash/blob/master/benchmark/string_short.svg) for generic usage.

--

* Do not use C++ iostream for serious file I/O applications.

--

* Use C pointer if you want to optimize for performance and *you do know what you are doing*.

--

* [Need to use STL with care.](https://www.youtube.com/watch?v=eICYHA-eyXM)

---

# Acknowledgment #

* Tue Ly

* Zac Bently (@zbently)
