/* global require */
"use strict";
var helper = require('./helper.js');
var q = require('q');
var FirefoxProfile = require('firefox-profile');

var config = {
    getMultiCapabilities: function() {
        var deferred = q.defer();

        var firefoxProfile = new FirefoxProfile();
        firefoxProfile.setPreference('general.useragent.override', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.11; rv:38.0) Gecko/20100101 Firefox/38.0 Protractor');
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
    },
    onPrepare: helper.onPrepare
};

if (helper.isSauceLabsRun()) {
    helper.enhanceConfigWithSauceLabsData(config);
}

exports.config = config;
