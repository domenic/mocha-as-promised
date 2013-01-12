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

describe "Use of promise-returning tests in conjunction with promise-returning hooks", =>
    [calledBefore, calledBeforeEach] = [false, false]

    before =>
        Q.resolve().then =>
            calledBefore = true

    beforeEach =>
        calledBefore.should.be.true

        Q.resolve().then =>
            calledBeforeEach = true

    it "should run the beforeEach hook asynchronously", =>
        calledBeforeEach.should.be.true

describe "Does not interfere with synchronous hooks", =>
    [calledBefore, calledBeforeEach] = [false, false]

    before =>
        calledBefore = true

    beforeEach =>
        calledBefore.should.be.true
        calledBeforeEach = true

    it "should run the beforeEach hook synchronously", =>
        calledBeforeEach.should.be.true
