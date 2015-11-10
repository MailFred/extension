/* global require, element, by, browser, protractor */
var chai = require('chai');
var chaiAsPromised = require('chai-as-promised');
chai.use(chaiAsPromised);

var expect = chai.expect;

module.exports = function() {
    'use strict';

    this.setDefaultTimeout(30 * 1000);

    this.When(/^I open the first email in the conversation view$/, function(callback) {
        element.all(by.css('table .zA')).first().click().then(callback);
    });

    this.Then(/^I should see the MailFred button$/, function() {
        var locator = by.css('.mailfred');
        browser.driver.wait(function() {
            return browser.driver.isElementPresent(locator);
        });
        expect(element(locator).isPresent()).to.eventually.equal(true);
    });

    this.Then(/^I should see the welcome dialog$/, function() {
        var locator = by.css('.mailfred-welcome-dialog');
        browser.driver.wait(function() {
            return browser.driver.isElementPresent(locator);
        });
        expect(element(locator).isPresent()).to.eventually.equal(true);
    });

    this.When(/^I click the auth dialog OK button$/, function(callback) {
        element(by.css('.mailfred-auth-ok')).click().then(callback);
    });

    this.When(/^I click the welcome dialog OK button$/, function(callback) {
        element(by.css('.mailfred-welcome-ok')).click().then(callback);
    });

    this.Then(/^I should see the auth popup$/, function(callback) {
        browser.getAllWindowHandles()
            .then(function(handles) {
                var mainHandle = handles[0];
                var popUpHandle = handles[1];
                browser.switchTo().window(popUpHandle);
                return browser.driver.executeScript('window.close();').then(function() {
                    return browser.switchTo().window(mainHandle);
                });
            })
            .then(callback);
    });
};
