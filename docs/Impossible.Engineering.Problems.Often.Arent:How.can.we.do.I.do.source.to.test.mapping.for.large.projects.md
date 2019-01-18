class: center, middle
# Impossible Engineering Problems Often Aren't: How can I do source to test mapping with AthenaNet codebase

---
# What is source to test mapping?

---
background-image: url(https://www.allearsenglish.com/wp-content/uploads/2014/02/why-you-cant-speak-English.jpg)

---

# How? #

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

- This approach does not scale if a software engineer want to qualify his changes that have not reached production yet.

- It take alot of time and resources to collect code coverage information for each merge request.

---

# What is the problem #

--

- **Give me all tests that I need to run before submitting my changes.**
 
