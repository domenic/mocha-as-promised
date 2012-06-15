var path = require("path");

var mochaPath = process.argv[1];
var desiredMochaPath = path.resolve(path.dirname(require.resolve("mocha")), "bin/_mocha");

if (mochaPath !== desiredMochaPath) {
    console.error("You need to run these tests with the copy of Mocha belonging to this package, not the global one. " +
                  "If you don't, the duck-punching doesn't quite work right, and they always pass!\n\nTry `npm test`.");
    process.exit(1);
}

var chai = require("chai");

var mocha = require("mocha");
var mochaAsPromised = require("../mocha-as-promised");

chai.should();

mochaAsPromised(mocha);
