/* global require, element, by, browser, protractor */
var myStepDefinitionsWrapper = function() {
    'use strict';

    //noinspection SpellCheckingInspection
    var chai = require('chai');
    //noinspection SpellCheckingInspection
    var chaiAsPromised = require('chai-as-promised');
    chai.use(chaiAsPromised);

    var expect = chai.expect;

    // Chai expect().to.exist syntax makes default jshint unhappy.
    // jshint expr:true

    /*
    // let's keep this in case the onPrepare should not work out at some point any more

    this.Given(/^I log into GMail$/, function(next) {
        browser.get('https://mail.google.com')
            .then(function() {
                element(by.id('Email')).sendKeys(process.env.GOOGLE_USER_EMAIL);
                element(by.id('Passwd')).sendKeys(process.env.GOOGLE_USER_PASSWORD);
                element(by.id('signIn')).click();
            })
            .then(function() {
                // security updates?
                var locator = by.id('save');
                return element.all(locator).then(function(elements) {
                    if (elements.length) {
                        elements.first().click();
                    }
                });
            })
            .then(function() {
                return browser.wait(function() {
                    return browser.getCurrentUrl().then(function(url) {
                        return /#inbox/.test(url);
                    });
                });
            })
            .then(function() {
                next();
            });

        // from: http://www.seleniumwiki.com/webdriver/gmail-sign-in-sign-out-using-selenium-webdriver/
        //browser.driver.findElement(by.xpath("//a[contains(text(),'Gmail')]")).click();
        //browser.driver.switchTo().frame("canvas_frame");
        // driver.FindElementByLinkText("Sign out").Click();
    });
    */


    this.When(/^I open the first email in the conversation view$/, function(callback) {
        element.all(by.css('table .zA')).first().click();
        callback();
    });

    this.Then(/^I should see the MailFred button$/, function(callback) {
        var locator = by.css('.mailfred');
        browser.wait(function() {
            return browser.isElementPresent(locator);
        });
        expect(element(locator)).to.eventually.notify(callback);
    });

    this.Then(/^I should see the welcome dialog$/, function(callback) {
        //browser.wait(function() { return false; }, 200000);

        browser.sleep(10000);
        var locator = by.css('.mailfred-welcome-dialog');
        browser.wait(function() {
            return browser.isElementPresent(locator);
        });
        expect(element(locator)).to.eventually.notify(callback);
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

module.exports = myStepDefinitionsWrapper;
