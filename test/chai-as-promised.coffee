"use strict"

Q = require("q")
chai = require("chai")
chaiAsPromised = require("chai-as-promised")

chai.use(chaiAsPromised)

chaiAsPromised.transferPromiseness = (assertion, promise) =>
    assertion.then = promise.then.bind(promise)
    assertion.inspect = promise.inspect.bind(promise)

test = (description, promiseFactory) =>
    describe description, =>
        promise = null

        before =>
            promise = promiseFactory()

        it "should be fulfilled", =>
            promise.inspect().state.should.equal("fulfilled")

describe "Use with Chai as Promised", =>
    test ".should.be.fulfilled", =>
        Q.resolve().should.be.fulfilled
    test ".should.be.rejected", =>
        Q.reject().should.be.rejected
    test ".should.be.rejected.with(TypeError, 'boo')", =>
        Q.reject(new TypeError("boo!")).should.be.rejectedWith(TypeError, "boo")
    test ".should.become(5)", =>
        Q.resolve(5).should.become(5)
    test ".should.eventually.be.above(2)", =>
        Q.resolve(5).should.eventually.be.above(2)

    test "should.eventually.have.length.above(0)", =>
        Q([1]).delay(100).should.eventually.have.length.above(0)
