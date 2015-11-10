/* global require */
"use strict";

var helper = require('./helper.js');
var path = require('path');

/**
 * Reads a given file path into a base64 encoded string
 *
 * @param path
 * @returns {String} base64-encoded file contents
 */
function fileToBase64String(path) {
    var fs = require('fs');
    return fs.readFileSync(path).toString('base64');
}

var chromeOptions = {
    args: [
        '--lang=en',
        '--user-agent="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/46.0.2490.71 Safari/537.36 Protractor"'
    ]
};

var config = {
    capabilities: {
        browserName: 'chrome',
        chromeOptions: chromeOptions
    },
    onPrepare: helper.onPrepare
};

if (helper.isSauceLabsRun()) {
    helper.enhanceConfigWithSauceLabsData(config);
    helper.enhanceCapabilitiesWithSauceLabsData(config.capabilities);

    var pathToCrx = 'build/mailfred-extension-' + helper.readPkg().version + '.crx';
    chromeOptions.extensions = [
        fileToBase64String(pathToCrx)
    ];
} else {
    var pathToChromeDir = path.join(__dirname, '..', 'chrome');
    chromeOptions.args.push('--load-extension=' + pathToChromeDir);
}

exports.config = config;
