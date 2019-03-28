class: center, middle
# Impossible Engineering Problems Often Aren't: How can I solve source to test mapping challenge for large codebases

---

# What do I do for the last two years? #

* My role is the mixture of a backend engineer and a SRE. We build, maintain, and operate a large distributed job excution system which processes more than 200 million requests per day.

* Write Perl, Bash, and Java code professionally.
  
* Write many tools (using C++) to speed up my workflow and development workflow at AthenaHealth.  

* Research about text processing algorithms.

---

# Introduction #

--
* Why do we need these [tools](https://github.com/hungptit/tools)?

--
* Comparison with other open source options.

--
* Tools are introduced in the topological sorted order i.e mfind, mlocate, fgrep, codesearch, and source2tests.

---

# Outline for each topic #

--
* Demo

--
* Benchmark results

--
* The analysis for each benchmark.

---
# mfind #

* A fast replacement for [GNU find](https://www.gnu.org/software/findutils/)

* More flexible and offer some features that [GNU find](https://www.gnu.org/software/findutils/) does not.

---
# Benchmark results #
---

# Benchmark results - Big folder #

``` text
ATH020224:benchmark hdang$ ./mfind -g big_folder
Celero
Timer resolution: 0.001000 us
-----------------------------------------------------------------------------------------------------------------------------------------------
     Group      |   Experiment    |   Prob. Space   |     Samples     |   Iterations    |    Baseline     |  us/Iteration   | Iterations/sec  |
-----------------------------------------------------------------------------------------------------------------------------------------------
big_folder      | gnu_find        |               0 |              20 |               1 |         1.00000 |    475287.00000 |            2.10 |
big_folder      | fd              |               0 |              20 |               1 |         1.09422 |    520067.00000 |            1.92 |
big_folder      | mfind_default   |               0 |              20 |               1 |         0.53738 |    255410.00000 |            3.92 |
big_folder      | mfind_dfs       |               0 |              20 |               1 |         0.52558 |    249803.00000 |            4.00 |
Complete.
```

---

# Benchmark results - Big folder with regex #

``` text
ATH020224:benchmark hdang$ ./mfind -g big_folder_regex
Celero
Timer resolution: 0.001000 us
-----------------------------------------------------------------------------------------------------------------------------------------------
     Group      |   Experiment    |   Prob. Space   |     Samples     |   Iterations    |    Baseline     |  us/Iteration   | Iterations/sec  |
-----------------------------------------------------------------------------------------------------------------------------------------------
big_folder_rege | gnu_find        |               0 |              20 |               1 |         1.00000 |    471865.00000 |            2.12 |
big_folder_rege | fd              |               0 |              20 |               1 |         0.96650 |    456056.00000 |            2.19 |
big_folder_rege | mfind_default   |               0 |              20 |               1 |         0.54251 |    255993.00000 |            3.91 |
big_folder_rege | mfind_dfs       |               0 |              20 |               1 |         0.53523 |    252554.00000 |            3.96 |
Complete.
```

---
# Why [mfind](https://github.com/hungptit/tools) is significantly faster than both [GNU find](https://www.gnu.org/software/findutils/) and [fd](https://github.com/sharkdp/fd.git) #

* File traversal algorithms.

* Optimized text search algorithms.

* All core algorithms are templatized so code are generated at compile time.

* Others
  * Minimum memory copy.
  * Cache line friendly.
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

# Benchmark results - non-git folder #

``` text
ATH020224:benchmark hdang$ time find ~/working/3p/include/ | wc
   16813   16813 1200669

real    0m0.192s
user    0m0.021s
sys     0m0.177s
ATH020224:benchmark hdang$ time fd . ~/working/3p/include/ | wc
   16812   16812 1183824

real    0m0.144s
user    0m0.168s
sys     0m0.677s
ATH020224:benchmark hdang$ time ../commands/mfind ~/working/3p/include/ | wc
   16812   16812 1183824

real    0m0.085s
user    0m0.018s
sys     0m0.067s
```

---
# mlocate #

--
* A compartible replacement for [GNU locate](https://www.gnu.org/software/findutils/).

--
* Can be 10x faster than [GNU locate](https://www.gnu.org/software/findutils/).

---

# Benchmark results using boost source code #

--
``` text
ATH020224:benchmark hdang$ ./locate_benchmark
Celero
Timer resolution: 0.001000 us
-----------------------------------------------------------------------------------------------------------------------------------------------
     Group      |   Experiment    |   Prob. Space   |     Samples     |   Iterations    |    Baseline     |  us/Iteration   | Iterations/sec  |
-----------------------------------------------------------------------------------------------------------------------------------------------
regex           | gnu_locate      |               0 |              10 |               1 |         1.00000 |    649553.00000 |            1.54 |
regex           | mlocate         |               0 |              10 |               1 |         0.06303 |     40943.00000 |           24.42 |
Complete.
```

---

# Why [mlocate](https://github.com/hungptit/tools) is 10x faster than [GNU locate](https://www.gnu.org/software/findutils/)? #

* [File reading algorithms](https://lemire.me/blog/2012/06/26/which-is-fastest-read-fread-ifstream-or-mmap/).

* [Text search algorithm](https://branchfree.org/2019/02/28/paper-hyperscan-a-fast-multi-pattern-regex-matcher-for-modern-cpus/).

* Optimized data structure for storing paths.

* All core algorithms are templatized so code are generated at compile time.

* Others
  * Minimum memory copy.
  * Cache line friendly.
  * All core algorithms are vectorized using SSE2/AVX2.

---

# fastgrep #

* fastgrep is created to address a real problem i.e log diving in production log with TB of text data.

* Build as a library so I can use it in other projects.

* Need a portable tool which can be used in any Linux system.

---

# Benchmark results - Single file #

``` text
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

``` text
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

* [File reading algorithms](https://lemire.me/blog/2012/06/26/which-is-fastest-read-fread-ifstream-or-mmap/).

* [Text search algorithm](https://branchfree.org/2019/02/28/paper-hyperscan-a-fast-multi-pattern-regex-matcher-for-modern-cpus/).

* [File traversal algorithms](https://github.com/hungptit/ioutils)

* All core algorithms are templatized so code are generated at compile time.

* Others
  * Minimum memory copy.
  * Cache line friendly.

---
# codesearch #

* Why?

  * grep like tools is only good for a medium number of files. If you have a codebase with millions lines of code then grep like tools do not work well.

  * Allow users to quickly search for desired text pattern.

  * Will significantly improve your development workflow especially you have to work with a lot of files everyday.

---

# Demo #

``` gettext-catalog
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
* There is a commercial version of codesearch/source2tests:

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
# Why? #

---
# What is the standard way to tackle source to test map challenge? #

* Use code coverage information i.e high-order analysis
  * Runtime complexity: O(NM), where N is the number of source lines and M is the number of tests.
  * Space complexity: O(NM)
  * Confidence score: High
  
* Use static text analysys i.e low-order analysis
  * Runtime complexity: O(N)
  * Space complexity: O(N)
  * Confidence score: Medium
  
* Use folder map i.e first or second order analysis.
  * Runtime complexity: O(N)
  * Space complexity: O(1)
  * Confidence level: Low

---

# What does source2tests do? #

* We use the static text analysis using the very fast text search engine which can process 3GB of text data per second per thread.

* The current version only support the first order analysis.

---

# Features #

* Work with any programming language.

* Work well for large codebase with million lines of code.

* Provide a command line interface.

---
class: center, middle

# Examples - Find all zstd tests #

``` text
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

# C++ performance tips #

* [Measure, measure, and measure.](https://www.youtube.com/watch?v=Qq_WaiwzOtI)

* Minimize memory copy/write/allocation operations.

* Try to vectorize your code if possible.

* Use boost libraries with care i.e perforamnce is not the first constraint of any boost libraries for example boost hash function is [really slow](https://github.com/hungptit/clhash/blob/master/benchmark/string_short.svg) for generic usage.

* Do not use C++ iostream for serious file I/O applications.

* Use C pointer if you want to optimize for performance and *you do know what you are doing*.

* [Need to use STL with care.](https://www.youtube.com/watch?v=eICYHA-eyXM)
