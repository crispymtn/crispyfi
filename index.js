#!/usr/bin/env node
// Enable CoffeeScript
require('coffee-script/register');
// Application config
var Config = require('./config.json');

// The Server
var ApiServer = require('apiserver');
var server = new ApiServer({ port: 8000 });
// Control modules used by the ApiServer
var SlackInterface = require('./lib/slack_interface/index')();

// Parse POST Payloads
server.use(ApiServer.payloadParser());
// Add control modules
server.addModule('1', 'slack_interface', SlackInterface);
// Routing
server.router.addRoutes([
  ["/handle", "1/slack_interface#handle"]
]);


// Let's go
server.listen();
console.info('Server running. Yay!');
