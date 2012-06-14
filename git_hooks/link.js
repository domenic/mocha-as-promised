var fs = require("fs");
var path = require("path");

["applypatch-msg", "commit-msg", "post-commit", "post-receive", "post-update", "pre-applypatch", "pre-commit",
 "prepare-commit-msg", "pre-rebase", "update"].forEach(function (hook) {
    var hookInSourceControl = path.resolve(__dirname, hook);

    if (path.existsSync(hookInSourceControl)) {
        var hookInHiddenDirectory = path.resolve(__dirname, "..", ".git", "hooks", hook);

        if (path.existsSync(hookInHiddenDirectory)) {
            fs.unlinkSync(hookInHiddenDirectory);
        }

        fs.linkSync(hookInSourceControl, hookInHiddenDirectory);
    }
});
