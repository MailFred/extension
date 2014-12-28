/* global require, process */
'use strict';

exports.isSauceLabsRun = function() {
    return !!process.env.SAUCE_USERNAME;
};

exports.isTravisRun = function() {
    return !!process.env.TRAVIS_BUILD_NUMBER;
};

exports.readPkg = function() {
    var grunt = require('grunt');
    return grunt.file.readJSON('package.json');
};


exports.enhanceConfigWithSauceLabsData = function(config) {
    config.sauceUser = process.env.SAUCE_USERNAME;
    config.sauceKey = process.env.SAUCE_ACCESS_KEY;
};

exports.enhanceCapabilitiesWithSauceLabsData = function(capabilities) {
    var pkg = exports.readPkg();
    capabilities.name = pkg.name;
    capabilities['custom-data'] = {
        release: pkg.version
    };

    if (exports.isTravisRun()) {
        capabilities.build = process.env.TRAVIS_BUILD_NUMBER;
    }
};

exports.onPrepare = function() {
    /* global browser, by */
    browser.ignoreSynchronization = true;
    browser.driver.get('https://mail.google.com');

    browser.driver.findElement(by.id('Email')).sendKeys(process.env.GOOGLE_USER_EMAIL);
    browser.driver.findElement(by.id('Passwd')).sendKeys(process.env.GOOGLE_USER_PASSWORD);
    browser.driver.findElement(by.id('signIn')).click();


    // security updates?
    var locator = by.id('save');

    browser.driver.findElements(locator).then(function(elements) {
        if (elements.length) {
            elements.first().click();
        }
    });

    browser.driver.wait(function() {
        return browser.driver.getCurrentUrl().then(function(url) {
            return /#inbox/.test(url);
        });
    });

    browser.driver.wait(function() {
        return browser.driver.isElementPresent(by.partialLinkText('Inbox'));
    });
};
