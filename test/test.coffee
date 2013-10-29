"use strict"

path = require("path")
Q = require("q")

mochaPath = path.resolve(process.argv[1], "../..")
Test = require(mochaPath).Test

describe "Mocha's `Test` class, after duck-punching", ->
    describe "when the function returns a promise fulfilled with no value", ->
        beforeEach ->
            @ran = false
            testFunc = =>
                process.nextTick => @ran = true
                return Q.resolve()
            @theTest = new Test("", testFunc)

        it "should invoke the done callback asynchronously with no argument", (done) ->
            @theTest.run =>
                @ran.should.be.true
                done()

    describe "when the function returns a promise fulfilled with a value", ->
        beforeEach ->
            @ran = false
            testFunc = =>
                process.nextTick => @ran = true
                return Q.resolve({})
            @theTest = new Test("", testFunc)

        it "should invoke the done callback asynchronously with no argument", (done) ->
            @theTest.run =>
                @ran.should.be.true
                done()

    describe "when the function returns a promise that is also a function", ->
        beforeEach ->
            @ran = false
            testFunc = =>
                process.nextTick => @ran = true
                functionPromise = () =>
                realPromise = Q.resolve({})
                functionPromise.then = realPromise.then.bind(realPromise)
                return functionPromise
            @theTest = new Test("", testFunc)

        it "should invoke the done callback asynchronously with no argument", (done) ->
            @theTest.run =>
                @ran.should.be.true
                done()

    describe "when the function returns a promise rejected with no reason", ->
        beforeEach ->
            # Q automatically gives `new Error()` if no rejection reason is supplied, i.e. it is impossible to create
            # a promise rejected with no reason in Q. Create a pseudo-promise manually to test this case.
            rejected = then: (f, r) => process.nextTick(r)
            @theTest = new Test("", => rejected)

        it "should invoke the done callback with a generic `Error`", (done) ->
            @theTest.run (err) =>
                err.should.be.instanceOf(Error)
                err.should.have.property("message")
                err.message.should.match(/rejected/)
                done()

    describe "when the function returns a promise rejected with a reason", ->
        beforeEach ->
            @err = new TypeError("boo!")
            @theTest = new Test("", => Q.reject(@err))

        it "should invoke the done callback with that reason", (done) ->
            @theTest.run (err) =>
                err.should.equal(@err)
                done()

    describe "when doing normal synchronous tests", ->
        describe "that succeed", ->
            beforeEach ->
                @theTest = new Test("", =>)

            it "should succeed normally", (done) ->
                @theTest.run(done)

        describe "that fail", ->
            beforeEach ->
                @err = new TypeError("boo!")
                @theTest = new Test("", => throw @err)

            it "should fail normally", (done) ->
                @theTest.run (err) =>
                    err.should.equal(@err)
                    done()

        describe "that return `null`", ->
            beforeEach ->
                @theTest = new Test("", => null)

            it "should succeed normally", (done) ->
                @theTest.run(done)

    describe "when doing normal asynchronous tests", ->
        describe "that succeed", ->
            beforeEach ->
                @theTest = new Test("", (done) => process.nextTick => done())

            it "should succeed normally", (done) ->
                @theTest.run(done)

        describe "that fail", ->
            beforeEach ->
                @err = new TypeError("boo!")
                @theTest = new Test("", (done) => process.nextTick => done(@err))

            it "should fail normally", (done) ->
                @theTest.run (err) =>
                    err.should.equal(@err)
                    done()

    describe "when printing test details", ->
        beforeEach ->
            @theTest = new Test("", => return "hello")

        it "should show the original code", ->
          @theTest.fn.toString().should.match /return \"hello\"/

