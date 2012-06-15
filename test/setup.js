var chai = require("chai");

var mocha = require("mocha");
var mochaAsPromised = require("../mocha-as-promised");

chai.should();

mochaAsPromised(mocha);
