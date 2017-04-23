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
  speaker: 'Galder Zamarreño'
  , slug: ''
  , location: 'Bangalore, India'
  , date: '2017-04-27 16:30'
  , talkTitle: 'Big Data In Action with Infinispan'
  , conferenceName: 'Great Indian Developer Summit'
  , conferenceLink: 'http://www.developermarch.com/developersummit/session.html?insert=Galder1'
  , speakerPhotoFilename: ''
  , conferenceLogoFilename: ''
};

var event2 = {
  speaker: 'Syed Rasheed, Cojan van Ballegooijen'
  , slug: ''
  , location: 'Boston, USA'
  , date: '2017-05-02 10:15'
  , talkTitle: 'Using real-time data to enable real-time analytics'
  , conferenceName: 'Red Hat Summit'
  , conferenceLink: 'https://rh2017.smarteventscloud.com/connect/sessionDetail.ww?SESSION_ID=10438'
  , speakerPhotoFilename: ''
  , conferenceLogoFilename: ''
};


var event3 = {
  speaker: 'Anthony Golia, Russ Popeil'
  , slug: ''
  , location: 'Boston, USA'
  , date: '2017-05-02 15:30'
  , talkTitle: 'Improving Financial Market Risk accuracy using JBoss Data Grid'
  , conferenceName: 'Red Hat Summit'
  , conferenceLink: 'https://rh2017.smarteventscloud.com/connect/sessionDetail.ww?SESSION_ID=108586'
  , speakerPhotoFilename: ''
  , conferenceLogoFilename: ''
};


var event4 = {
  speaker: 'Kim Palko, Ted Jones'
  , slug: ''
  , location: 'Boston, USA'
  , date: '2017-05-04 11:30'
  , talkTitle: 'Building Big Data analytics apps in OpenShift'
  , conferenceName: 'Red Hat Summit'
  , conferenceLink: 'https://rh2017.smarteventscloud.com/connect/sessionDetail.ww?SESSION_ID=105079'
  , speakerPhotoFilename: ''
  , conferenceLogoFilename: ''
};


var event5 = {
  speaker: 'Ugo Landini, Sanne Grinovero, Andrea Leoncini, Andrea Tarocchi'
  , slug: ''
  , location: 'Boston, USA'
  , date: '2017-05-04 13:00'
  , talkTitle: 'Lab: Highly available and scalable complex event processing'
  , conferenceName: 'Red Hat Summit'
  , conferenceLink: 'https://rh2017.smarteventscloud.com/connect/sessionDetail.ww?SESSION_ID=100472'
  , speakerPhotoFilename: ''
  , conferenceLogoFilename: ''
};


var event6 = {
  speaker: 'Sanne Grinovero'
  , slug: ''
  , location: 'London, UK'
  , date: '2017-05-11 13:10'
  , talkTitle: 'Use Hibernate OGM to tame an Infinispan distributed K/V store'
  , conferenceName: 'Devoxx UK'
  , conferenceLink: 'http://cfp.devoxx.co.uk/2017/talk/IKD-0045/Quickstart_Hibernate_OGM_to_tame_an_Infinispan_distributed_key%2Fvalue_store'
  , speakerPhotoFilename: ''
  , conferenceLogoFilename: ''
};


var event7 = {
  speaker: 'Galder Zamarreño'
  , slug: ''
  , location: 'Malaga, Spain'
  , date: '2017-05-19 11:00'
  , talkTitle: 'Learn Functional Reactive Apps with Elm, Node.js and Infinispan'
  , conferenceName: 'J On The Beach'
  , conferenceLink: 'https://jonthebeach.com/schedule#learn-how-to-build-functional-reactive-applications-with-elm-node-js-and-infinispan'
  , speakerPhotoFilename: ''
  , conferenceLogoFilename: ''
};


var event8 = {
  speaker: 'Galder Zamarreño'
  , slug: ''
  , location: 'Berlin, Germany'
  , date: '2017-06-13 16:30'
  , talkTitle: 'Big Data In Action with Infinispan'
  , conferenceName: 'Berlin Buzzwords'
  , conferenceLink: 'https://berlinbuzzwords.de/17/session/big-data-action-infinispan'
  , speakerPhotoFilename: ''
  , conferenceLogoFilename: ''
};


// var event9 = {
//   speaker: 'Sanne Grinovero'
//   , slug: ''
//   , location: 'Copenhagen, Denmark'
//   , date: '2017-06-19 00:00'
//   , talkTitle: 'One ORM to rule them all'
//   , conferenceName: 'JDK IO'
//   , conferenceLink: 'https://jdk.io/talks/183-one-orm-to-rule-them-all'
//   , speakerPhotoFilename: ''
//   , conferenceLogoFilename: ''
// };


var events = [event1, event2, event3, event4, event5, event6, event7, event8];


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
