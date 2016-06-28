var express = require('express');
var app = express();
var expressWs = require('express-ws')(app);


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
var store;


app.listen(3000, function () {
  console.log('Event manager app listening on port 3000!');
  store = connect()
    .then(function(client) { return initStore(client); })
    .catch(function(error) {
      console.log('Error connecting or initialising data: ' + error);
    });
  ;
});


function connect() {
  var infinispan = require('infinispan');
  return infinispan.client(
    {port: 11422, host: '127.0.0.1'}
    , {cacheName: 'default'}
  );
}


var event1 = {
  speaker: 'Will Burns, John Osborne & Divya Mehra'
  , slug: ''
  , location: 'San Francisco, USA'
  , date: '30 June 2016, 16:45'
  , talkTitle: 'Big data processing and analytics in Red Hat JBoss Data Grid 7'
  , conferenceName: 'Red Hat Summit'
  , conferenceLink: 'https://rh2016.smarteventscloud.com/connect/sessionDetail.ww?SESSION_ID=42051&tclass=popup#.V1l5Ads356c.twitter'
  , speakerPhotoFilename: ''
  , conferenceLogoFilename: ''
};


var event2 = {
  speaker: 'Kimberly Palko, Cojan van Ballegoojen & Divya Mehra'
  , slug: ''
  , location: 'San Francisco, USA'
  , date: '30 June 2016, 11:30'
  , talkTitle: 'Real-time data services with Red Hat JBoss Data Virtualization and Red Hat JBoss Data Grid'
  , conferenceName: 'Red Hat Summit'
  , conferenceLink: 'https://rh2016.smarteventscloud.com/connect/sessionDetail.ww?SESSION_ID=45619&tclass=popup#.V1l5lmRWPOA.twitter'
  , speakerPhotoFilename: ''
  , conferenceLogoFilename: ''
};

var event3 = {
  speaker: 'Nasu, Saran, Murphy & Elrahal'
  , slug: ''
  , location: 'San Francisco, USA'
  , date: '30 June 2016, 15:30'
  , talkTitle: 'The intersection of business rules management and big data'
  , conferenceName: 'Red Hat Summit'
  , conferenceLink: 'https://rh2016.smarteventscloud.com/connect/sessionDetail.ww?SESSION_ID=41750'
  , speakerPhotoFilename: ''
  , conferenceLogoFilename: ''
};


var events = [event1, event2, event3];


function initStore(client) {
  return client.clear() // Clear any backend data
    .then(initEvents(client)) // Add initial events
    .then(addEventListener(client)) // Add listener for events
    .then(addSearchScript(client)) // Add search script
    .then(function() { return client; }) // Chain client invocations
    .catch(function(err) {
      console.log('Error initialising store: ' + err);
    });
}


function initEvents(client) {
  return function() {
    var pairs = _.map(events, function(event) {
      var eventId = newEventId();
      var eventAsString = JSON.stringify(event);
      return {key: eventId, value: eventAsString};
    });

    return client.putAll(pairs);
  };
}


function addSearchScript(client) {
  return function() {
    var Promise = require('promise');
    var readFile = Promise.denodeify(require('fs').readFile);
    return readFile('search-events.js').then(function(script) {
      return client.addScript('search-events', script.toString());
    });
  };
}


app.get('/', function (req, res) {
  res.send('Hello World!');
});


app.get('/events', function (req, res) {
  store.then(function(client) {
    var fetchEvents = client.iterator(10).then(function(it) {
      return iterate(it, [], function(entry) {
        return entry.value;
      });
    });

    return fetchEvents.then(function(events) {
      var sorted = sortByDate(events);
      res.send('[' + sorted.join(',') + ']');
    });
  });
});


function iterate(it, events, fn) {
  return it.next().then(function(entry) {
    return !entry.done
      ? iterate(it, cat(events, [JSON.parse(fn(entry))]), fn)
      : events;
  });
}


function sortByDate(events) {
  var sorted = _.sortBy(events, 'date');
  return _.map(sorted, function (e) {
    return JSON.stringify(e);
  });
}


app.ws('/events', function(ws, req) {
  console.log('Websocket connection open');
});


var eventsWss = expressWs.getWss('/events');


function addEventListener(client) {
  return function() {
    return client.addListener('create', function(key) {
      client.get(key).then(function(value) {
        eventsWss.clients.forEach(function(wsClient) {
          wsClient.send(value);
        });
      });
    });
  };
}


app.post('/events', function (req, res) {
  var event = req.body;
  var eventId = newEventId();
  store.then(function(client) {
    client.putIfAbsent(eventId, event).then(function(stored) {
      res.send('{"succeed":' + stored + '}');
    });
  });
});


app.get('/search', function(req, res) {
  store.then(function(client) {
    client.execute('search-events', {query: req.query.q})
      .then(function(result) {
        res.send(result);
      });
  });
});


function newEventId() {
  return _.uniqueId('event_');
}


////////////////////////////
// Functional helper methods
////////////////////////////


// Conncat and return an updated array
function cat() {
  var head = _.first(arguments);
  if (existy(head))
    return head.concat.apply(head, _.rest(arguments));
  else
    return [];
}


// Check if a value exists
function existy(x) {
  return x != null;
};
