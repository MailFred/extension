module.exports = function() {
    'use strict';
    var debug = false;
    var infix = debug ? '' : '.min';

    function css(target) {
        return {
            "expand": true,
            "cwd": "shared/css/build",
            "src": [
                "**/*.css"
            ],
            "dest": target + "/data/shared/css"
        };
    }

    function src(target) {
        return {
            "expand": true,
            "cwd": "shared/js/src",
            "src": [
                "**/*.coffee"
            ],
            "dest": target + "/data/shared/js"
        };
    }

    function scripts(target) {
        return {
            "expand": true,
            "cwd": "shared/js/build",
            "src": [
                debug ? "**/*.{js,map}" : '**/*.min.js'
            ],
            "dest": target + "/data/shared/js"
        };
    }

    function statics(target) {
        return {
            "expand": true,
            "cwd": "shared",
            "src": [
                'images/**',
                'bower_components/eventr/build/eventr' + infix + '.js',
                'bower_components/gmailr/build/gmailr' + infix + '.js',
                'bower_components/gmailui/build/gmailui' + infix + '.js',
                'bower_components/headjs/dist/1.0.0/head.load' + infix + '.js',
                'bower_components/jquery/dist/jquery' + infix + '.js',
                'bower_components/jquery-deparam/jquery.ba-deparam' + infix + '.js',
                'bower_components/lodash/dist/lodash' + infix + '.js',
                'bower_components/moment/min/moment' + infix + '.js',
                'bower_components/pikaday/pikaday.js',
                'bower_components/pikaday/css/pikaday.css',
                'bower_components/q/q.js',
                'bower_components/trackjs/tracker.js'
            ],
            "dest": target + "/data/shared"
        };
    }

    var config = {
        "options": {
            "timestamp": true
        },
        "shared.styles": {
            "files": [
                css('chrome'),
                css('firefox')
            ]
        },
        "shared.scripts": {
            "files": [
                scripts('chrome'),
                scripts('firefox')
            ]
        },
        "shared.static": {
            "files": [
                statics('chrome'),
                statics('firefox')
            ]
        }
    };

    if (debug) {
        config['shared.scripts'].files.push(src('chrome'));
        config['shared.scripts'].files.push(src('firefox'));
    }


    return config;
};
