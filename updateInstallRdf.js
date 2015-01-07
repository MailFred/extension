#!/usr/bin/env node
/* global require */
(function() {
    'use strict';
    var fs = require('fs'),
        xml2js = require('xml2js'),
        Q = require('q');

    var version = 'add-update-key-option-github-joscha';
    var rdfFile = 'tmp/mozilla-addon-sdk/addon-sdk-'+version+'/app-extension/install.rdf';

    Q.all([
        Q.nfcall(fs.readFile, 'firefox/appvers.txt', 'utf8'),
        Q.nfcall(fs.readFile, rdfFile, 'utf-8')
    ])
        .then(function buildObj(data) {
            return {
                appvers: data[0],
                rdf: data[1]
            };
        })
        .then(function gatherVersionTuples(files) {
            var tuples = {};
            files.appvers.split(/\n/).forEach(function(line) {
                line = line.trim();
                if (!line) {
                    return;
                }
                var tuple = line.split(/\s+/);
                var id = tuple[0];
                var maxVersion = tuple[1];
                tuples[id] = maxVersion;
            });
            files.appvers = tuples;
            return files;
        })
        .then(function parseRdf(files) {
            var parser = new xml2js.Parser();
            return Q.nfcall(parser.parseString, files.rdf).then(function(xml) {
                files.rdf = xml;
                return files;
            });

        })
        .then(function replaceMaxVersion(data) {
            var targetApplications = data.rdf.RDF.Description[0]['em:targetApplication'];
            targetApplications.forEach(function(targetApplication) {
                var description = targetApplication.Description[0];
                var id = description['em:id'][0];
                if (typeof data.appvers[id] !== 'undefined') {
                    description['em:maxVersion'][0] = data.appvers[id];
                }
            });
            return data.rdf;
        })
        .then(function buildRdf(xmlObj) {
            return new xml2js.Builder().buildObject(xmlObj);
        })
        .then(function writeRdfFile(xml) {
            return Q.nfcall(fs.writeFile, rdfFile, xml)
        })
        .then(function done() {
            console.log('written "'+rdfFile+'"');
        })
        .catch(function() {
            console.error(arguments);
        });


})();
