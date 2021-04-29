class: center, middle
# Impossible Engineering Problems Often Aren't: How can we do source to test mapping for large codebases

---

# [What is a software bug?](https://en.wikipedia.org/wiki/Software_bug) #

--

*A software bug is an error, flaw, failure or fault in a computer program or system that causes it to produce an incorrect or unexpected result, or to behave in unintended ways.*

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

* We do not know if a line of code works or not until it is executed by our business logics.

--

* Modyifying our codebase will transform/change its behaviors. Automated unit and integration testsuites **give us confidence** that we have not broken anything significant.

--

* Tests can be used for profiling, to help us understand changes in our system's performance, and raise a flag if something degrades significantly.

---
# How can we qualify our changes? #

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
* What is the current number of Perl files?
``` shell
fast-locate '[.](pm|pl|t)$' | wc -l
58258
```

--
* What is the current number of test files?
``` shell
fast-locate '(_Test[.]pm|[.]t)$' | wc -l
14749
```

--
* What is the number of LOC?
``` shell
codesearch '\w*;$' -p '([.]pm|[.]pl)$' | wc -l
3712218
```

---
# What is the complexity of our Perl codebase? (cont) #

--
* What is the current number of test LOC?
``` shell
codesearch '\w*;$' -p '(_Test[.]pm|[.]t)$' | wc -l
850256
```

--
* What is the estimated runtime?
``` shell
>>> 14749 * 10 / 3600.0
40.96944444444444
```


---
# What do we currently do to qualify a task?

--
``` shell
```

---
# Is it correct? #

--

``` shell
```

---

# What is a source to test map? #

--
*It is a map from a source code line to test files or test points that will execute or excersise this source code line.*

---
# Why do we need source to test mapping? #

--

* **Productivity:** Reduce the qualification time in development and staging.

--

* **Reliability:** Boost our confidence that we have not broken anything significant.

--

* **Scalability:** Have **similar results** as running all tests with much lower runtime complexity i.e much a smaller set of tests.


---
class: center, middle
# How can we figure out tests need to run from given source files? #

---

# What is the problem that we want to solve? #

--

* **Give me a set of tests that excersise given set of source code lines.**

---

# Possible solutions #

--
* Build the source to test map using code coverage information

    * Pros: This high-order dependency analysis will definitely give us the best results.

    * Cons: Very expensive.

--
* Estimated runtime in CPU hours
``` shell
>>> 40 * (58258 - 14749 - 5104)
1536200
```

--
- Estimated storage in GB
``` shell
>>> (100 * 20) * (58258 - 14749 - 5104) * 14749 / pow(2,30)
1055
```

---

# Are we stuck? #

--

* Can we trade accuracy for run-time and storage complexity?

--

* Shall we use lower order analysis i.e first-order or second-order?

---

# What are the new constraints/requirements #

--

* **Does not need to be 100% correct.**

--

* Does not need to be very fine grain at test point level. We will use first-order dependency analysis instead.

--

* Have to be fast otherwise no-one will ever use it.

--

* Support all development and staging environments.

---

# Alternative solutions #

--
* **Compute the dependency map using module dependency analysis**

    * Pros: Do not need to run tests.

    * Cons: Expensive since it take **~100 CPU hours** to collect the module dependency map and the confident level is **Medium**.

--

* Manually map from source folders to test folders.

    * Pros: Simple and fast.

    * Cons: The confidence level is very **Low**.

---

# How can we do it? #

--

* Solution: **Perform static code analysis using a very fast text searching engine.**

--

* Pros: Fast and scalable.

--

* Cons: The confidence level is **Medium**.

---

# What are the challenges? #

--

* Build a very fast text search engine that can handle large codebases i.e million lines of code.

--

* The text search engine can quickly ingest GB of text data.

---

# [codesearch](https://github.com/hungptit/tools/blob/master/README.md): A fast and efficient code search engine #

--

* Is written using modern C++.

--

* Can process about **3GB of raw text data per second**.

--

* Support a extendend regular expression syntax.

--

* A user friendly command line interface.

---
class: center, middle
# Demo #

---

# Typical examples #

--
``` shell
codesearch 'search_pattern'
```

---

# Typical examples (cont) #

--
* A simple aglimpse command
``` shell
```

--
* Equivalent commands using codesearch/source2tests
``` shell
```

---

# More options #

``` shell
```

---

# source2tests: A fast and efficient source to test mapping engine #

--

* Can support **multiple programming languages**.

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
```

--
* Find all tests that use/require **Document**
``` shell
```

--
* Get the coverage report for WorkUnit::Daemon::Trap package

``` shell
```
---

# How can we use these commands in our development/staging environments? #

--

* All binaries are **statistically linked** and they should work on any MacOS, Linux, and Window Linux Subsystem environment.

* You can find all binaries from this folder **~hdang/public_html/tools**

---
# FAQs #

* How can I use your tools?
All binaries can be found [here](https://github.com/hungptit/tools) and they should work on any development servers.

* Where can I find binaries for MacOS?
Binaries for MacOS can be downloaded from this [link](https://github.com/hungptit/tools/tree/master/Darwin/x86_64).

* Do you support Window Linux Subsystem?
Binaries for Window Linux Subsystem can be downloaded from this [link](https://github.com/hungptit/tools/tree/master/Linux/x86_64/4.4.0-17134-Microsoft).

* Do you have any document for your tools?
You can get basic information about my tool [here](https://github.com/hungptit/tools/blob/master/README.md)  or ping me over slack for more information.

---
class: center, middle
# Thank you #

---

# Acknowledgement #

* Mia Morreti

* Zac Bentley

---

# Lessons learned from creating several fastest algorithms #

* Measure, measure, and measure

* The combination of C programming style and C++ template will give us the best code interm of performance.

* Have a deep knowledge about the executed environment.

* Pay attention to Big O.

* Know our data and use the best algorithms if possible.

* We can make our C++ binary portable.

* STL and Boost data structures and algorithms are not fast except **std::vector**, **std::array**, and **std::string**.
