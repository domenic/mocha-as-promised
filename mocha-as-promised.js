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
            // Run the original `fn`, assuming its asynchronous (no harm passing `done` if it's not).
            var retVal = fn(done);

            if (isPromise(retVal)) {
                // If we get a promise back...
                retVal.then(
                    function () {
                        // On fulfillment, ignore the fulfillment value and call `done()` with no arguments.
                        done();
                    },
                    function (reason) {
                        // On rejection, make sure there's a rejection reason, then call `done` with it.
                        if (reason === null || reason === undefined) {
                            reason = new Error("Promise rejected with no rejection reason.");
                        }
                        done(reason);
                    }
                );
            } else if (originalThisFn.length === 0) {
                // If we weren't asynchronous, call `done()` now. If we were then `fn` will call it eventually.
                done();
            }
        }

        OriginalRunnable.call(this, title, newFn);
    };
    mocha.Runnable.prototype = OriginalRunnable.prototype;
    mocha.Runnable.prototype.constructor = mocha.Runnable;
};
