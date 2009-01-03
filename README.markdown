README
======

etap is a collection of Erlang modules that provide a TAP testing client library. These modules allow developers to create extensive and comprehensive tests covering many aspects of application and module development. This includes simple assertions, exceptions, the application behavior and event web requests. This library was originally written by Jeremy wall.

As per the TAP wiki:

> TAP, the Test Anything Protocol, is a simple text-based interface between testing modules in a test harness. TAP started life as part of the test harness for Perl but now has implementations in C/C++, Python, PHP, Perl and probably others by the time you read this. 

These modules are not meant to compete with eunit, but to offer a more general testing facility that isn't provides by eunit.

    http://en.wikipedia.org/wiki/Test_Anything_Protocol
    http://testanything.org/wiki/index.php/Main_Page

CREATING TESTS
==============

A "test" is any number of etap:\* or etap\_\*:\* tests that are part of a test plan. When a plan is created using etap:plan/1, a process is started that tracks the status of the tests executed and handles diagnostic output.

Consider the following example test plan:

    etap:plan(3),
    etap:ok(true, "the 'true' atom is recognized"),
    etap:is(1 + 1, 2, "simple math"),
    etap:isnt(2 + 2, 5, "some would argue"),
    etap:end_tests().

At this time, etap does not support pattern matching. To work around this there are a number of utility tests that can be used. The etap:any/3, etap:none/3 and etap:fun_is/3 use functions to return either 'true' or 'false'.

    Numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9],
    FunWithNumbers = fun(X) case X of [1, 2, 3 | _] -> true; _ -> false end end,
    etap:fun_is(FunWithNumbers, Numbers, "Match the first three numbers").

There are many examples in t/*.erl.

BUILD & INSTALL
===============

To build this library, from the root directory execute the `make` command. You should also execute the `make test` command to verify that the library functions correctly on your system. If you have the Perl module TAP::Harness you can use it to collect and display test results using the `make prove` target.

    $ make
    $ make test
    $ make prove

If you choose to run the `make test` command then please be sure to `make clean` after to remove any of the temporary beam files created by the tests in the `t/` directory.

The included tests cover the basic functionality of the etap modules. They can also be used as a reference when writing your own tests. 

To install etap you need to create the `etap/bin/` directory in your current Erlang library and copy all of the .beam files created by the `make` file.

    $ sudo mkdir -p /usr/lib/erlang/lib/etap-0.3.2/ebin
    $ make clean && make
    $ sudo cp ebin/*.beam /usr/lib/erlang/lib/etap-0.3.2/ebin/

SUPPORTED FUNCTIONALITY
=======================

There are a number of proposals listed on the TAP wiki that are not supported by this library. Please be aware of this when creating your tests.

 * LIMITED SUPPORTED: TAP diagnostic syntax
 * LIMITED SUPPORTED: TAP meta information
 * LIMITED SUPPORTED: TAP logging syntax
 * NOT SUPPORTED: Test groups
 * NOT SUPPORTED: Test blocks
 * LIMITED SUPPORTED: SKIP
 * NOT SUPPORTED: TODO
 * LIMITED SUPPORTED: TAP datetime

CREDITS
=======

2008 Nick Gerakines<br />
2007-2008 Jeremy Wall<br />
2008 Jacob Vorreuter
