"use strict"

Q = require("q")
Runnable = require("mocha").Runnable

# NOTE: due to an awesome "feature" of Mocha, if you set `this.runnable` in the test context (e.g. in a `beforeEach`),
# everything breaks. So we use `@test = new Runnable` instead of the more obvious `@runnable = new Runnable`.

describe "Modifications to mocha's `Runnable` constructor", ->
    describe "when the function returns a promise fulfilled with no value", ->
        beforeEach ->
            @ran = false
            testFunc = =>
                process.nextTick => @ran = true
                return Q.resolve()
            @test = new Runnable("", testFunc)

        it "should invoke the done callback asynchronously with no argument", (done) ->
            @test.run =>
                @ran.should.be.true
                done()

    describe "when the function returns a promise fulfilled with a value", ->
        beforeEach ->
            @ran = false
            testFunc = =>
                process.nextTick => @ran = true
                return Q.resolve({})
            @test = new Runnable("", testFunc)

        it "should invoke the done callback asynchronously with no argument", (done) ->
            @test.run =>
                @ran.should.be.true
                done()

    describe "when the function returns a promise rejected with no reason", ->
        beforeEach ->
            # Q automatically gives `new Error()` if no rejection reason is supplied, i.e. it is impossible to create
            # a promise rejected with no reason in Q. Create a pseudo-promise manually to test this case.
            rejected = then: (f, r) => process.nextTick(r)
            @test = new Runnable("", => rejected)

        it "should invoke the done callback with a generic `Error`", (done) ->
            @test.run (err) =>
                err.should.be.instanceOf(Error)
                err.should.have.property("message")
                err.message.should.match(/rejected/)
                done()

    describe "when the function returns a promise rejected with a reason", ->
        beforeEach ->
            @err = new TypeError("boo!")
            @test = new Runnable("", => Q.reject(@err))

        it "should invoke the done callback with that reason", (done) ->
            @test.run (err) =>
                err.should.equal(@err)
                done()

    describe "when doing normal synchronous tests", ->
        describe "that succeed", ->
            beforeEach ->
                @test = new Runnable("", =>)

            it "should succeed normally", (done) ->
                @test.run(done)

        describe "that fail", ->
            beforeEach ->
                @err = new TypeError("boo!")
                @test = new Runnable("", => throw @err)

            it "should fail normally", (done) ->
                @test.run (err) =>
                    err.should.equal(@err)
                    done()

    describe "when doing normal asynchronous tests", ->
        describe "that succeed", ->
            beforeEach ->
                @test = new Runnable("", (done) => process.nextTick => done())

            it "should succeed normally", (done) ->
                @test.run(done)

        describe "that fail", ->
            beforeEach ->
                @err = new TypeError("boo!")
                @test = new Runnable("", (done) => process.nextTick => done(@err))

            it "should fail normally", (done) ->
                @test.run (err) =>
                    err.should.equal(@err)
                    done()
