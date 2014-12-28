module.exports = function (grunt, options) {
    'use strict';

    var files = [
        "package.json",
        "bower.json",
        "chrome/manifest.json",
        "firefox/package.json"
    ];

    return {
        "options": {
            "files": files,
            /*
            // TODO does not work any more with grunt-load-tasks
            "updateConfigs": [
                "pkg",
                "manifest",
                "firefoxPackage"
            ],
            */
            "commit": true,
            "commitMessage": "Release v%VERSION%",
            "commitFiles": files,
            "createTag": true,
            "tagName": "v%VERSION%",
            "tagMessage": "Version %VERSION%",
            "push": true,
            "pushTo": "origin",
            "gitDescribeOptions": "--tags --always --abbrev=1 --dirty=-d",
            "globalReplace": false
        }
    };
};
