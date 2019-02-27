class: center, middle
# Impossible Engineering Problems Often Aren't: How can we do source to test mapping with AthenaNet codebase

---

# What is a software bug? #

--
- Definition: [A software bug is an error, flaw, failure or fault in a computer program or system that causes it to produce an incorrect or unexpected result, or to behave in unintended ways.](https://en.wikipedia.org/wiki/Software_bug)

--
- [How do we get a software bug](https://www.softwaretestinghelp.com/why-does-software-have-bugs/)?
  - Miscommunication or no communication
  - Software complexity
  - Programming errors.
  - Changing requirements.
  - Time pressure
  - Software development tools.
  - Obsolete automation scripts
  - Undertesting.

---
# [Why do we need to write test](https://www.quora.com/Why-is-testing-code-important)? #

--
- We do not know if a line of code works or not until it is executed/triggered using our required use cases.

--
- Modyifying our code will transform/change its behaviors. An automated unit and integration testsuites give us confidence that we have broken anything significant.

--
- Tests can be used for profiling, to help us understand changes in our system's performance, and raise a flag if something degrades significantly.

---
# How do we run tests to qualify our changes? #

--
- The complexity and runtime of our test suite will increase quadratically with the size of the codebase.

--
- Run all tests.
  - Pros: 
    - Runtime complexity: High.
  - Cons:
    - Confidence level: High

--
- Run a predefined set of tests for each modules.
  - Pros: 
    - Runtime complexity: Low.
  - Cons:
    - Confidence level: Low

---
# What is the complexity of AthenaNet codebase? #

--
- The current number of Perl files

``` shell
[prod PTEST1] hdang@dev116:~/p4_dev116> mlocate '[.](pm|pl|t)$' | wc
  58258   58258 3905353
```

--
- The number of tests

``` shell
[prod PTEST1] hdang@dev116:~/p4_dev116> mlocate '(_Test[.]pm|[.]t)$' | wc
  14749   14749 1133612
```

--
- The number of source lines

``` shell
[prod PTEST1] hdang@dev116:~/p4_dev116> codesearch '\w*;$' -p '([.]pm|[.]pl)$' | wc
3536002 15046121 353993898
[prod PTEST1] hdang@dev116:~/p4_dev116> codesearch '\w*;$' -p '(_Test[.]pm)$' | wc
 542015 1928026 53546006
```
--
- The number of test lines

``` shell
[prod PTEST1] hdang@dev116:~/p4_dev116> codesearch '\w*;$' -p '(_Test[.]pm|[.]pl)$' | wc
 771955 3013430 76629514
```

--
- Estimated runtime?

``` shell
>>> 14749 * 10 / 3600.0
40.96944444444444
```

<!-- Explain why we need source to test mapping -->
---
# Why do we need source to test mapping? #
background-image: url(https://www.allearsenglish.com/wp-content/uploads/2014/02/why-you-cant-speak-English.jpg)

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
# Standard approaches #

--
- Build the source to test map using code coverage information
  - Pros: Gives the best results.
  - Cons: Very time consumming and it is impractical in reallife.

--
- Get the dependency map using module dependency analysis
  - Pros: Compurational complexity is much less compared with the code coverage approach.
  - Cons:
    - Cannot collect module dependency map for large packages.
    - Still expensive for our codebase i.e take about ~100hours for AthenaNet.

--
- Manually map from test folders to source packages.
  - Pros: Simple
  - Cons: The confidence level is **Low**.

---

# What is the problem that we want to solve? #

--

- **Give me all tests that I need to run when submitting/qualifying my changes.** within a reasonable amount of time i.e some seconds.

---

# What are the requirements? #

--
- Can return the list of tests need to run quickly i.e at most couple of seconds.

--
- **Just work.**
  - Work out of the box for any users in any Linux, Window Linux Subsystem, and MacOS environments.
  - Friendly command line interface.
  - Support HTTP/REST interfaces (nice to have).

---

# How can we do it #

--
- **Static code analysis**

---

# What are the challenges? #

--
- A very fast text search engine that can handle a decent amount of requests per second for large codebases i.e million lines of code.

--
- Can quickly ingest GB of text data. 

--
- A user friendly command line interface.

--
- A fast HTTP/REST interface (nice to have).

---

# codesearch: A fast and efficient code search engine #

--
- A very fast code search engine written using modern C++.

--
- Strongly focused in user experience.

---
class: center, middle
# Simple examples #

--
* [aglimpse usage](https://social.athenahealth.com/people/nandreev/blog/2019/02/07/speeding-up-athenacodeutilsafeuse-preloading-subsystems)

``` shell
aglimpse 'SafeUse(' | grep -v intranet | grep -v _Test.pm | grep -v '/test/'|  wc -l
```

--
* A similar codesearch/source2tests command

``` shell
source2tests 'SafeUse\(' -p '_Test[.]pm'
```


---

# Search for lines that match a given pattern #

--

``` shell
[prod PTEST1] hdang@dev116:~/p4_dev116> codesearch MakeTrap
prod//perllib/Athena/TAGS:1290830:sub MakeTrap WorkUnit::Daemon::ScaleMonitor::MakeTrap403,11775
prod//perllib/Athena/WorkUnit/Daemon/ScaleMonitor.pm:394:# MakeTrap
prod//perllib/Athena/WorkUnit/Daemon/ScaleMonitor.pm:403:sub MakeTrap {
prod//perllib/Athena/WorkUnit/Daemon/ScaleMonitor.pm:510:       my $trap = $self->MakeTrap($args);
prod//scripts/app/platform/athenaworker/snmp_test.pl:51:        $trap = WorkUnit::Daemon::ScaleMonitor::MakeTrap({
prod//tags:187435:MakeTrap      ./perllib/Athena/WorkUnit/Daemon/ScaleMonitor.pm        /^sub MakeTrap {$/;"    s
prod//test/perl/WorkUnit/Daemon/ScaleMonitor/t/unit/make_trap.t:28:     $monitor->MakeTrap({
prod//test/perl/WorkUnit/Daemon/ScaleMonitor/t/unit/make_trap.t:66:     $monitor->MakeTrap({
```

---

# Search for lines that match a given pattern from specific files #

--

``` shell
[prod PTEST1] hdang@dev116:~/p4_dev116> codesearch MakeTrap -p '[.]t$'
prod//test/perl/WorkUnit/Daemon/ScaleMonitor/t/unit/make_trap.t:28:     $monitor->MakeTrap({
prod//test/perl/WorkUnit/Daemon/ScaleMonitor/t/unit/make_trap.t:66:     $monitor->MakeTrap({
```


---

# More options #

``` shell
[prod PTEST1] hdang@dev116:~/p4_dev116> codesearch MakeTrap -p '.*trap*[.]t$' -c -i
prod//test/perl/WorkUnit/Daemon/ScaleMonitor/t/unit/make_trap.t:28:     $monitor->MakeTrap({
prod//test/perl/WorkUnit/Daemon/ScaleMonitor/t/unit/make_trap.t:66:     $monitor->MakeTrap({
```

---

# source2tests: A fast and efficient source to test mapping engine #

--
- Can support multiple languages.

--
- Work well with large code base i.e several million lines of code.

--
- Low latency

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
- **Our solution**: Static linked binaries.

``` shell
[prod PTEST1] hdang@dev116:~/p4_dev116> ldd ~/bin/codesearch
        not a dynamic executable
[prod PTEST1] hdang@dev116:~/p4_dev116> ldd ~/bin/source2tests
        not a dynamic executable
```

---

# Q/A #
