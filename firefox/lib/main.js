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
            self.data.url('shared/bower_components/q/q.js'),
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
        contentScriptWhen: 'ready',
        contentScriptOptions: {
            version: self.version,
            baseUrl: self.data.url('')
        },
        onAttach: setupListener
    });

    var simplePrefs = require('sdk/simple-prefs');
    var simpleStorage = require('sdk/simple-storage');

    function initDebug() {
        simpleStorage.storage.debug = simplePrefs.prefs.debug;
    }
    function initEmail() {
        simpleStorage.storage.email = simplePrefs.prefs.email;
    }

    simplePrefs.on('debug', initDebug);
    simplePrefs.on('email', initEmail);



    function setupListener(worker) {
        worker.port.on('facade.message', function(args) {
            var ret = null;
            switch(args.action) {
                case 'notification':
                    require('sdk/notifications').notify({
                        title: args.title,
                        text: args.message,
                        iconURL: args.icon
                    });
                    break;
                case 'i18n':
                    ret = require('sdk/l10n').get(args.key);
                    break;
            }
            if (args.callback) {
                worker.port.emit(args.callback, ret);
            }
        });
    }
})();
