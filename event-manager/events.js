var express = require('express');
var app = express();

var bodyParser = require('body-parser');
app.use(bodyParser.json()); // support json encoded bodies
app.use(bodyParser.urlencoded({ extended: true })); // support encoded bodies
app.use(bodyParser.text()); // support text bodies

app.use(function(req, res, next) {
  res.header("Access-Control-Allow-Origin", "*");
  res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
  next();
});

var _ = require('underscore');
var infinispan = require('infinispan');
var store;

app.listen(3000, function () {
  console.log('Event managaer app listening on port 3000!');
  store = infinispan.client({port: 11422, host: '127.0.0.1'})
    .then(function(client) {
      return client.clear() // Clear any backend data
        .then(function() { return client; }); // Chain invocations
    });
});

app.get('/', function (req, res) {
  res.send('Hello World!');
});

app.post('/events', function (req, res) {
  // console.log('POST on /events: ' + JSON.stringify(req.body));
  // console.log('Title: ' + req.body.title);
  // console.log(req.headers);
  console.log(req.body);
  var event = req.body;
  var eventId = _.uniqueId('event_');
  store.then(function(client) {
    client.putIfAbsent(eventId, event).then(function(stored) {
      console.log("Add event: " + stored);
      res.send('{"succeed":' + stored + '}');
    });
  });
  // console.log(req.title);
  // console.log('Title: ' + req.body.title);
  // res.send('{"succeed":true}');
});
