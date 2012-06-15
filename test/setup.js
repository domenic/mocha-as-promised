var chai = require("chai");
var chaiAsPromised = require("chai-as-promised");

var mocha = require("mocha");
var mochaAsPromised = require("../mocha-as-promised");

chai.use(chaiAsPromised);
chai.should();

mochaAsPromised(mocha);
