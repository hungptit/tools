class: center, middle
# Impossible Engineering Problems Often Aren't: How can we do source to test mapping for large codebases

---

# [What is a software bug?](https://en.wikipedia.org/wiki/Software_bug) #

--

**A software bug is an error, flaw, failure or fault in a computer program or system that causes it to produce an incorrect or unexpected result, or to behave in unintended ways.**

---
# [Why does software have bugs?](https://www.softwaretestinghelp.com/why-does-software-have-bugs/)

--

- Miscommunication or no communication

--

- Software complexity

--
- Programming errors.

--

- Changing requirements.

--

- Time pressure

--

- Software development tools.

--

- Obsolete automation scripts

--

- Overconfidence about our code.

---

# [Why do we need to write test?](https://www.quora.com/Why-is-testing-code-important) #

--

* We do not know if a line of code works or not until it is executed by our business logics i.e tests.

--

* Modyifying our codebase will transform/change its behaviors. An automated unit and integration testsuites **give us confidence** that we have not broken anything significant.

--

* Tests can be used for profiling, to help us understand changes in our system's performance, and raise a flag if something degrades significantly.

---
# How do we qualify our changes? #

--

*The complexity and runtime of our test suite will increase quadratically with the size of the codebase.*

--

* Run all tests.

    * Confidence level: High

    * Runtime complexity: High.

--

* Run a predefined set of tests for each modules.

    * Runtime complexity: Low.

    * Confidence level: Low

---
# What is the complexity of our Perl codebase? #

--
``` shell
linux:~> mlocate '[.](pm|pl|t)$' | wc
  58258   58258 3905353

linux:~> mlocate '(_Test[.]pm|[.]t)$' | wc
  14749   14749 1133612

linux:~> codesearch '\w*;$' -p '([.]pm|[.]pl)$' | wc
3536002 15046121 353993898

linux:~> codesearch '\w*;$' -p '(_Test[.]pm)$' | wc
 542015 1928026 53546006
```

--
``` shell
linux:~> codesearch '\w*;$' -p '(_Test[.]pm|[.]pl)$' | wc
 771955 3013430 76629514
```

--
``` shell
>>> 14749 * 10 / 3600.0
40.96944444444444
```

---
# Why do we need source to test mapping? #

--

* **Productivity:** Reduce the qualification time in development and staging.

--

* **Reliability:** Boost our confidence that we have not broken anything significant.

--

* **Scalability:** Have **a similar results** as running all tests with much lower runtime complexity i.e much a smaller set of tests.

---
# What do we currently do?

--
``` shell
The following are commands to execute the available automated tests:

 utest --ignorewip --failedonly --color WorkUnit::Daemon

 athenax perl-test WorkUnit::Daemon
 athenax perl-test WorkUnit::Daemon::Trap


Did you verify that all the tests listed above pass? (yes/no)
```

---
# What should we do? #

--

``` shell
source2tests '(WorkUnit::Daemon|ScaleMonitor)' --perl-tap-tests | wc
     62      62    4517

source2tests '(WorkUnit::Daemon|ScaleMonitor)' --perl-legacy-tests | wc
      3       3     151
```

---
class: center, middle
# How can we figure out tests need to run from given source files? #

---

# What is the problem that we want to solve? #

--

* **Give me a set of tests that I need to run to qualify source code changes.**

---

# What are the requirements? #

--

* Can return the list of tests need to run quickly i.e at most couple of seconds.

--

* **Just work.**

    * Work out of the box for supported development and staging environments.

    * A friendly command line interface.

    * Support HTTP/REST interfaces (nice to have).

---
# Possible solutions #

--
* Build the source to test map using code coverage information

    * Pros: Gives the best results.

    * Cons: Very expensive **> 100 CPU hours**.

--
* **Compute the dependency map using module dependency analysis**

    * Pros: Do not need to run tests.

    * Cons: Very expensive **~100 CPU hours**.

--

* Manually map from source folders to test folders.

    * Pros: Simple and fast.

    * Cons: The confidence level is very **Low**.

---

# How can we do it? #

--

* **Perform static code analysis using a very fast text searching engine.**

---

# What are the challenges? #

--

* A very fast text search engine that can handle large codebases i.e million lines of code.

--

* Can quickly ingest GB of text data.

---

# codesearch: A fast and efficient code search engine #

--

* A very fast code search engine written using modern C++ and it can process about **3GB of raw text data per second**.

--

* A user friendly command line interface.

---
class: center, middle
# Simple examples #

---

# Simple examples #

--
* A simple aglimpse command
``` shell
aglimpse 'SafeUse\(' | grep -E 'prod.*_Test[.]pm' |  wc -l
272
```

--
* Equivalent commands using codesearch/source2tests
``` shell
codesearch 'SafeUse\(' -p 'prod.*_Test[.]pm' |  wc -l
272
source2tests 'SafeUse\(' -p 'prod.*_Test[.]pm' |  wc -l
70
```

---

# More options #

``` shell
linux:~> codesearch maketrap -p '.*trap*[.]t$' -c -i
prod//test/perl/WorkUnit/Daemon/ScaleMonitor/t/unit/make_trap.t:28:     $monitor->MakeTrap({
prod//test/perl/WorkUnit/Daemon/ScaleMonitor/t/unit/make_trap.t:66:     $monitor->MakeTrap({
```

---

# source2tests: A fast and efficient source to test mapping engine #

--

* Can support **multiple languages**.

--

* Work well with large code base i.e several million lines of code.

---
class: center, middle
# Typical examples #

---

# Finding tests that covered your modules #

--
* Find all TAP tests related to **WorkUnit::Daemon**
``` shell
linux:~> time source2tests WorkUnit::Daemon --perl-tap-tests | wc
0.37user 0.35system 0:00.72elapsed 101%CPU (0avgtext+0avgdata 145984maxresident)k
0inputs+0outputs (0major+56347minor)pagefaults 0swaps
     62      62    4517
```

--
* Find all tests that use/require **Document**
``` shell
time source2tests '(use|require)\s+Document' -p '(_Test[.]pm|[.]t)$' | wc
1.19user 1.16system 0:02.33elapsed 101%CPU (0avgtext+0avgdata 228732maxresident)k
0inputs+0outputs (0major+157566minor)pagefaults 0swaps
    263     263   17979
```

---

# How can we use these commands in our development/staging environments? #

--

* All binaries are statistical linked and they should work on any MacOS, Linux, and Window Linux Subsystem machine

---
# FAQs #

* How can use your tools?
All binaries can be found here **~hdang/bin** and they should work on any development servers.

* How can I download binaries for MacOS?
Binaries for MacOS can be downloaded from this [link](https://github.com/hungptit/tools/tree/master/Darwin/x86_64).

* Do you have any document for your tools?
*The confluence page will be available soon*. In the mean time, you can get basic information about my tool [here](https://github.com/hungptit/tools/blob/master/README.md)  or ping me over slack for more information.

---
class: center, middle
# Thank you #
