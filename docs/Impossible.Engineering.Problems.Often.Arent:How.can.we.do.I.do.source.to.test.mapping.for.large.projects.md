class: center, middle
# Impossible Engineering Problems Often Aren't: How can we do source to test mapping with AthenaNet codebase

---
# What is source to test mapping?

---
background-image: url(https://www.allearsenglish.com/wp-content/uploads/2014/02/why-you-cant-speak-English.jpg)

---

# Why do we need source to test mapping? #

--

- The complexity and runtime of our test suite will increase quadratically with the size of the codebase.

---

# How about our code base #

--
- How many tests do we have?
``` shell
[prod PTEST1] hdang@dev116:~/p4_dev116> mlocate '(Test[.]pm|[.]t)$' | wc
  15629   15629 1207885
```

--
- Estimated runtime?

---
# What do we currently do?

--
``` shell
Code quality ratings (see https://intranet.athenahealth.com/wiki/node.esp?ID=124500 for more info):
/home/hdang/p4_dev116/prod/perllib/Athena/WorkUnit/Daemon.pm 0.59
/home/hdang/p4_dev116/prod/perllib/Athena/WorkUnit/Daemon/Trap.pm 0.76
Run $INTRANET_HOME/scripts/code_quality.pl --print --verbose for more details.

The following are commands to execute the available automated tests:
 utest --ignorewip --failedonly --color WorkUnit::Daemon
 $AX_HOME/athenax perl-test WorkUnit::Daemon
 $AX_HOME/athenax perl-test WorkUnit::Daemon::Trap


Did you verify that all the tests listed above pass? (yes/no)
```

--

``` shell
[prod PTEST1] hdang@dev116:~/p4_dev116> $AX_HOME/athenax perl-test WorkUnit::Daemon
Testing under /home/hdang/p4_dev116/athenax/release
Running tests for modules: WorkUnit::Daemon

Run: /home/hdang/p4_dev116/prod/local/5.16/bin/prove /home/hdang/p4_dev116/prod/test/perl/WorkUnit/Daemon/t/unit/basic.t

/home/hdang/p4_dev116/prod/test/perl/WorkUnit/Daemon/t/unit/basic.t .. ok
All tests successful.
Files=1, Tests=1,  1 wallclock secs ( 0.03 usr  0.00 sys +  0.82 cusr  0.13 csys =  0.98 CPU)
Result: PASS
```

--

``` shell
[prod PTEST1] hdang@dev116:~/p4_dev116> $AX_HOME/athenax perl-test WorkUnit::Daemon::Trap
Testing under /home/hdang/p4_dev116/athenax/release
Running tests for modules: WorkUnit::Daemon::Trap

Run: /home/hdang/p4_dev116/prod/local/5.16/bin/prove /home/hdang/p4_dev116/prod/test/perl/WorkUnit/Daemon/Trap/t/make_trap.t /home/hdang/p4_dev116/prod/test/perl/WorkUnit/Daemon/Trap/t/send_trap.t

/home/hdang/p4_dev116/prod/test/perl/WorkUnit/Daemon/Trap/t/make_trap.t .. ok
/home/hdang/p4_dev116/prod/test/perl/WorkUnit/Daemon/Trap/t/send_trap.t .. ok
All tests successful.
Files=2, Tests=6,  3 wallclock secs ( 0.02 usr  0.01 sys +  1.91 cusr  0.34 csys =  2.28 CPU)
Result: PASS
```

---

# What is the minimum number of tests that we need to run? #

--

``` shell
[prod PTEST1] hdang@dev116:~/p4_dev116> source2tests '(WorkUnit::Daemon|ScaleMonitor)' --perl-tap-tests | wc
     62      62    4517
[prod PTEST1] hdang@dev116:~/p4_dev116> source2tests '(WorkUnit::Daemon|ScaleMonitor)' --perl-legacy-tests | wc
      3       3     151
```

---
class: center, middle
# How can we compute the source to test map? #

---
# Straightforward approach #

- Run code coverage for the whole code base to collect the map from a test to a source code file for **every new merge request**.

- Create a reverse graph from the test to a source code line.

- For given change list or pull request find all tests that we need to run to pre-qualify our changes.

---

# Problem #

--

- We have to run **N * M** tests to collect all required code coverage information.

    - We can reduce the complexity of the collecting code coverage information by limiting to the scope of the map within modules and team's code base.


--
- At the level of AthenaNet codebase this task is **an impossible mission**.

    - This approach does not scale if a software engineer want to qualify his changes that have not reached production yet.

    - It take alot of time and resources to collect code coverage information for each merge request.

---

# What is the problem #

--

- **Give me all tests that I need to run before submitting my changes.**

---

# How can we redefine our problem? #

--
- For a given code change
  - Give me a list of tests that I need to run to boost my confidence about my change within a reasonable amount of time.
  - Test information must be up-to-date with my current change.

---

# How can we do it #

--
- A code search engine can give us a decent relationship between source files and test files.


---

# What is the new challenge? #

--
- Create a very fast code search engine that can handle
  - Large code base
  - Handle a decent amount of requests per second.
  - Provide command line/REST/HTTP interfaces.

---

# codesearch: A fast and efficient code search engine #

--
- Written using modern C++.

--
- Strongly focused in user experience.

--
- Build on top of very high performance libraries such as hyperscan, ioutils, utils, zstd, and rocksdb.

--
- Include many lessons learned from building fastgrep and ioutils.

---
class: center, middle
# Simple examples #

--
* [aglimpse usage](https://social.athenahealth.com/people/nandreev/blog/2019/02/07/speeding-up-athenacodeutilsafeuse-preloading-subsystems)

``` shell
aglimpse 'SafeUse(' | grep -v intranet | grep -v _Test.pm | grep -v '/test/'|  wc -l
```

--
* Similar codesearch/source2tests command

``` shell
source2tests 'SafeUse\(' -p '_Test[.]pm'
```


---

# Search for lines that match a given pattern #


---

# Search for lines that match a given pattern from specific files #

---

# More fancy options #

---

# source2tests: A fast and efficient source to test mapping engine #

--
- Can support multiple languages.

--
- Work well with large code base i.e several million lines of code.

--
- The response time for one request is a fraction of second.

---
class: center, middle
# Typical examples #

---

# Finding tests that covered your modules #

---

``` shell
[prod PTEST1] hdang@dev116:~/p4_dev116> time source2tests WorkUnit::Daemon --perl-tap-tests | wc
0.37user 0.35system 0:00.72elapsed 101%CPU (0avgtext+0avgdata 145984maxresident)k
0inputs+0outputs (0major+56347minor)pagefaults 0swaps
     62      62    4517
```

---

# How can we deployment in supported environments #

--
- Support environments: MacOS, Linux, and Linux Window Subsystem.

--
- Dockers or VMs?

--
- Our solution: Static linked binaries.


---

# Q/A #
