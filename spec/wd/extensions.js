var assert = require('assert');

module.exports = {
    screentest: function (title, options, cb) {
        if (!cb) {
            cb = options;
            options = {};
        }

        this
            .screenstory(title)
            .webdrivercss(title, options, function (err, res) {
                assert.equal(err, null, 'error while taking screenshot');
                assert.equal(res.misMatchPercentage < 5, true, 'screenshot mismatch');
            })
            .call(cb);
    }
};
