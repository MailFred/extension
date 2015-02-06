/* global module, require */
module.exports = function() {
    'use strict';

    var fs = require('fs');
    var updateKey = fs.readFileSync(__dirname + '/../certs/firefox/updateRdfKeyFile.pub', 'utf8').trim();
    var lines = updateKey.split('\n');
    if (lines[0].indexOf('---') === 0) {
        lines.shift(); // remove -----BEGIN PUBLIC KEY-----
    }
    if (lines[lines.length - 1].indexOf('---') === 0) {
        lines.pop(); // remove -----END PUBLIC KEY-----
    }
    updateKey = lines.join('');
    return {
        "release": {
            "options": {
                "mozilla-addon-sdk": "latest",
                "extension_dir": "firefox",
                "dist_dir": "build",
                "arguments": [
                    // This is done by uhura
                    //'--update-link=http://www.mailfred.de/extension/firefox/mailfred.signed.xpi',
                    '--update-url=http://extension.mailfred.de/firefox/update.rdf',
                    '--update-key=' + updateKey
                ].join(' ')
            }
        }
    };
};
