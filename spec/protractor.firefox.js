/* global require */
"use strict";
var helper = require('./helper.js');

var config = {
    getMultiCapabilities: (function() {
        var q = require('q');
        var FirefoxProfile = require('firefox-profile');
        var deferred = q.defer();

        var firefoxProfile = new FirefoxProfile();
        firefoxProfile.addExtension('build/mailfred.xpi', function() {
            firefoxProfile.encoded(function(encodedProfile) {
                var capabilities = {
                    browserName: 'firefox',
                    firefox_profile: encodedProfile
                };
                if (helper.isSauceLabsRun()) {
                    capabilities.username = process.env.SAUCE_USERNAME;
                    capabilities.accessKey = process.env.SAUCE_ACCESS_KEY;
                    helper.enhanceCapabilitiesWithSauceLabsData(capabilities);
                }

                deferred.resolve([capabilities]);
            });
        });

        return deferred.promise;
    })(),
    onPrepare: helper.onPrepare
};

if (helper.isSauceLabsRun()) {
    helper.enhanceConfigWithSauceLabsData(config);
}

exports.config = config;
