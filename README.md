crap-features
=============

Bucketize phpunit CRAP scores to identify risky features.

```bash
coffee crap-features.coffee
```

The [CRAP Index](http://googletesting.blogspot.com/2011/02/this-code-is-crap.html) 
is a metric to gauge code maintainability. It is provided by PHPUnit and combines
cyclomatic code complexity with unit test coverage to determine files and methods
that are highly risky.

This script attempts to take the data one step further by bucketing code into groups.
Rather than simply identifying that a file or method is risky, it is nice to know
when a feature or group of code is risky.

This is intended to help with code reviews and pre-deployment. It's also useful
to determine which code is overdue for refactoring, or simply paying down some
tech debt with unit tests.
