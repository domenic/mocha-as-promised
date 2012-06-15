"use strict";

function isPromise(x) {
    return typeof x.then === "function";
}

var duckPunchedAlready = false;

module.exports = function (mocha) {
    if (duckPunchedAlready) {
        return;
    }
    duckPunchedAlready = true;

    var OriginalRunnable = mocha.Runnable;
    mocha.Runnable = function (title, fn) {
        function newFn(done) {
            var retVal = fn(done);
            if (isPromise(retVal)) {
                retVal.then(
                    function () { done(); },
                    function (reason) { done(reason); }
                );
            } else if (originalThisFn.length === 0) {
                done();
            }
        }

        OriginalRunnable.call(this, title, newFn);
    };
    mocha.Runnable.prototype = OriginalRunnable.prototype;
    mocha.Runnable.prototype.constructor = mocha.Runnable;
};
