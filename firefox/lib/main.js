/* global require */
(function() {
    'use strict';

    var pageMod = require('sdk/page-mod');
    var self = require('sdk/self');
    var debug = false;
    var debugInfix = debug ? '' : '.min';

    pageMod.PageMod({
        include: [
            '*.mail.google.com'
        ],
        contentStyleFile: [
            './shared/css/styles.css',
            './shared/bower_components/pikaday/css/pikaday.css'
        ],
        contentScriptFile: [
            self.data.url('shared/js/facade' + debugInfix + '.js'),
            self.data.url('shared/bower_components/q/q.js'),
            self.data.url('shared/js/trackjs' + debugInfix + '.js'),
            self.data.url('shared/bower_components/trackjs/tracker.js'),
            self.data.url('shared/bower_components/lodash/dist/lodash' + debugInfix + '.js'),
            self.data.url('shared/bower_components/jquery/dist/jquery' + debugInfix + '.js'),

            self.data.url('shared/bower_components/moment/min/moment.min.js'),
            self.data.url('shared/bower_components/pikaday/pikaday.js'),

            self.data.url('shared/bower_components/headjs/dist/1.0.0/head.load' + debugInfix + '.js'),

            self.data.url('shared/js/bootstrap' + debugInfix + '.js'),

            self.data.url('shared/bower_components/eventr/build/eventr' + debugInfix + '.js'),
            self.data.url('shared/bower_components/gmailui/build/gmailui' + debugInfix + '.js'),
            self.data.url('shared/js/content' + debugInfix + '.js')
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
