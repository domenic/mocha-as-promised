"use strict"

Q = require("q")

describe "Direct usage of promise-returning tests", =>
    it "should work for a promise fulfilled with no value", =>
        Q.resolve()

    it "should work for a promise fulfilled with a value", =>
        Q.resolve({})

    it "should run through an entire promise chain", =>
        timeout = setTimeout(
            => throw new Error("The timeout wasn't cleared, so the promise chain must not have run"),
            100
        )

        Q.delay(5).then =>
            Q.delay(5).then =>
                clearTimeout(timeout)
