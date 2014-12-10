/* global require */
(function() {
    'use strict';

    var pageMod = require('sdk/page-mod');
    var self = require('sdk/self');

    pageMod.PageMod({
        include: [
            '*.mail.google.com'
        ],
        contentStyleFile: [
            self.data.url('shared/css/styles.css'),
            self.data.url('shared/bower_components/pikaday/css/pikaday.css')
        ],
        contentScriptFile: [
            self.data.url('shared/js/facade.min.js'),
            self.data.url('shared/js/trackjs.min.js'),
            self.data.url('shared/bower_components/trackjs/tracker.js'),
            self.data.url('shared/bower_components/lodash/dist/lodash.min.js'),
            self.data.url('shared/bower_components/jquery/dist/jquery.min.js'),

            self.data.url('shared/bower_components/moment/min/moment.min.js'),
            self.data.url('shared/bower_components/pikaday/pikaday.js'),

            self.data.url('shared/bower_components/yepnope/yepnope.1.5.4-min.js'),

            self.data.url('shared/js/bootstrap.min.js'),

            self.data.url('shared/bower_components/eventr/build/eventr.min.js'),
            self.data.url('shared/bower_components/gmailui/build/gmailui.min.js'),
            self.data.url('shared/js/content.min.js')
        ],
        contentScriptWhen: 'ready'
    });
})();
