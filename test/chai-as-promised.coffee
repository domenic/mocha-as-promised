"use strict"

Q = require("q")
chai = require("chai")
chaiAsPromised = require("chai-as-promised")

chai.use(chaiAsPromised)

describe "Use with Chai as Promised", =>
    it ".should.be.fulfilled", =>
        Q.resolve().should.be.fulfilled
    it ".should.be.rejected", =>
        Q.reject().should.be.rejected
    it ".should.be.rejected.with(TypeError, 'boo')", =>
        Q.reject(new TypeError("boo!")).should.be.rejected.with(TypeError, "boo")
    it ".should.become(5)", =>
        Q.resolve(5).should.become(5)
    it ".should.eventually.be.above(2)", =>
        Q.resolve(5).should.eventually.be.above(2)
