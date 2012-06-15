"use strict";

function isPromise(x) {
    return typeof x === "object" && typeof x.then === "function";
}

var duckPunchedAlready = false;

module.exports = function (mocha) {
    if (duckPunchedAlready) {
        return;
    }
    duckPunchedAlready = true;

    // Sooooo, this is a huge hack. We want to intercept calls to `Runnable`, but we can't just replace it because it's
    // a module export which other parts of Mocha use directly. Fortunately, they all use it in the same way:
    // `Runnable.call(this, title, fn)`. Thus if we take control of the `.call` method (i.e. shadow the one inherited
    // from `Function.prototype`), we have our interception hook.
    var callOriginalRunnable = Function.prototype.call.bind(mocha.Runnable);

    mocha.Runnable.call = function (thisP, title, fn) {
        function newFn(done) {
            // Run the original `fn`, passing along `done` for the case in which it's callback-asynchronous. Make sure
            // to forward the `this` context, since you can set variables and stuff on it to share within a suite.
            var retVal = fn.call(this, done);

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
            } else if (fn.length === 0) {
                // If `fn` is synchronous (i.e. didn't have a `done` parameter and didn't return a promise), call `done`
                // now. (If it's callback-asynchronous, `fn` will call `done` eventually since we passed it in above.)
                done();
            }
        }

        // Now that we have wrapped `fn` inside our promise-interpreting magic, call the original `mocha.Runnable`
        // constructor but give it the magic `newFn` instead of the mundane `fn`.
        callOriginalRunnable(thisP, title, newFn);
    };
};
