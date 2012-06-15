"use strict"

sinon = require("sinon")
Runnable = require("mocha").Runnable

fulfilled = (val) =>
    then: (f, r) => process.nextTick(=> f(val))
rejected = (err) =>
    then: (f, r) => process.nextTick(=> r(err))

# NOTE: due to an awesome "feature" of Mocha, if you set `this.runnable` in a `beforeEach` or other text context,
# everything breaks. So we use `@test = new Runnable` instead of the more obvious `@runnable = new Runnable`.

describe "Modifications to mocha's `Runnable.prototype.run` method", ->
    describe "when the function returns a promise fulfilled with no value", ->
        beforeEach ->
            @ran = false
            testFunc = =>
                process.nextTick => @ran = true
                return fulfilled()
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
                return fulfilled({})
            @test = new Runnable("", testFunc)

        it "should invoke the done callback asynchronously with no argument", (done) ->
            @test.run =>
                @ran.should.be.true
                done()

    describe "when the function returns a promise rejected with no reason", ->
        beforeEach ->
            @test = new Runnable("", => rejected())

        it "should invoke the done callback with a generic `Error`", (done) ->
            @test.run (err) =>
                err.should.be.instanceOf(Error)
                err.message.should.match(/rejected/)
                done()

    describe "when the function returns a promise rejected with a reason", ->
        beforeEach ->
            @err = new TypeError("boo!")
            @test = new Runnable("", => rejected(@err))

        it "should invoke the done callback with that reason", (done) ->
            @test.run (err) =>
                err.should.equal(@err)
                done()
