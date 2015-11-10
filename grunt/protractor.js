module.exports = function() {
    'use strict';

    function clone(o) {
        return JSON.parse(JSON.stringify(o));
    }

    var args = {
        "framework": "cucumber",
        "seleniumAddress": "http://localhost:4444/wd/hub",
        "specs": ["spec/cucumber/**/*.feature"],
        "cucumberOpts": {
            "require": "cucumber/step_definitions/my_steps.js",
            "tags": "@dev",
            "format": "pretty"
        }
    };

    var config = {
        "options": {
            "getPageTimeout": 30000,
            "args": args,
            "keepAlive": true,
            "noColor": false
        },
        "chrome": {
            "configFile": "spec/protractor.chrome.js"
        },
        "firefox": {
            "configFile": "spec/protractor.firefox.js"
        }
    };

    // generates firefox.remote and chrome.remote task(s)
    ['firefox', 'chrome'].forEach(function(browser) {
        var o = config[browser + '.remote'] = clone(config[browser]);
        var clonedArgs = clone(args);
        clonedArgs.seleniumAddress = '';
        o.options = {
            keepAlive: false,
            args: clonedArgs
        };
    });

    return config;
};
