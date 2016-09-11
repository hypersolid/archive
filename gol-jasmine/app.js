require("!style!css!./style.css");

var Field = require('./lib/Field');
var Colony = require('./lib/Colony');
var Cell = require('./lib/Cell');

field = new Field();
field.init();
field.rgo();
