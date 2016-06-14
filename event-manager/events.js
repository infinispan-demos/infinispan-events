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
  speaker: 'Will Burns & John Osborne'
  , slug: ''
  , location: 'San Francisco, USA'
  , date: '30 June 2016'
  , talkTitle: 'Big data processing and analytics in Red Hat JBoss Data Grid 7'
  , conferenceName: 'Red Hat Summit'
  , conferenceLink: 'https://rh2016.smarteventscloud.com/connect/sessionDetail.ww?SESSION_ID=42051&tclass=popup#.V1l5Ads356c.twitter'
  , speakerPhotoFilename: ''
  , conferenceLogoFilename: ''
};

var event2 = {
  speaker: 'Kimberly Palko & Van Halbert'
  , slug: ''
  , location: 'San Francisco, USA'
  , date: '30 June 2016'
  , talkTitle: 'Real-time data services with Red Hat JBoss Data Virtualization and Red Hat JBoss Data Grid'
  , conferenceName: 'Red Hat Summit'
  , conferenceLink: 'https://rh2016.smarteventscloud.com/connect/sessionDetail.ww?SESSION_ID=45619&tclass=popup#.V1l5lmRWPOA.twitter'
  , speakerPhotoFilename: ''
  , conferenceLogoFilename: ''
};

var event3 = {
  speaker: 'Galder Zamarreño & Divya Mehra'
  , slug: ''
  , location: 'San Francisco, USA'
  , date: '28 June 2016'
  , talkTitle: 'Building reactive applications with Node.js and Red Hat JBoss Data Grid'
  , conferenceName: 'DevNation'
  , conferenceLink: 'http://www.devnation.org/#44484'
  , speakerPhotoFilename: ''
  , conferenceLogoFilename: ''
};

var events = [event1, event2, event3];

function initStore(client) {
  return client.clear() // Clear any backend data
    .then(initEvents(client)) // Add initial events
    .then(function() { return client; }); // Chain client invocations
}

function initEvents(client) {
  return function() {
    var pairs = _.map(events, function(event) {
      var eventId = newEventId();
      var eventAsString = JSON.stringify(event);
      return {key: eventId, value: eventAsString};
    });

    return client.putAll(pairs);
    // var Promise = require('promise');
    // return Promise.all(_.map(events, function(event) {
    //   var eventId = newEventId();
    //   var eventAsString = JSON.stringify(event);
    //   return client.putIfAbsent(eventId, eventAsString);
    // })).then(function() { return client; });
  };
}

app.get('/', function (req, res) {
  res.send('Hello World!');
});

app.get('/events', function (req, res) {
  store.then(function(client) {
    var fetchEvents = client.iterator(10).then(function(it) {
      return iterate(it, [], function(entry) {
        // console.log('Return entry: ' + entry.value);
        // console.log('Entry done? ' + entry.done);
        return entry.value;
      });
    });
    // var events = [];
    // var fetchEvents = client.iterator(1).then(function(it) {
    //   return iteratorLoop(it, it.next(), function(entry) {
    //     if (!entry.done) {
    //       events.push(entry.value);
    //       console.log('Push entry: ' + entry.value);
    //       console.log('Entry done? ' + entry.done);
    //     }
    //     return entry;
    //   });
    // });

    return fetchEvents.then(function(events) {
      // console.log(events);
      res.send('[' + events.join(',') + ']');
      // res.json(events);
    });
  });
});

function iterate(it, events, fn) {
  return it.next().then(function(entry) {
    // if (!entry.done) {
    //   var event = fn(entry);
    //   console.log('Event: ' + event);
    //   var newEvents = cat(events, [event]);
    //   console.log('New events: ' + newEvents);
    //   return iterate(it, newEvents, fn);
    // }
    // return events;

    return !entry.done
      ? iterate(it, cat(events, [fn(entry)]), fn)
      : events;
  });
}

// Loop through iterator until all elements have been retrieved
// function iteratorLoop(it, promise, fn) {
//   return promise.then(fn).then(function (entry) {
//     return !entry.done ? iteratorLoop(it, it.next(), fn) : entry;
//   });
// }


// app.get('/events', function (req, res) {
//   store.then(function(client) {
//     var events = [];
//     var fetchEvents = client.iterator(1).then(function(it) {
//       return iteratorLoop(it, it.next(), function(entry) {
//         if (!entry.done) {
//           events.push(entry.value);
//           console.log('Push entry: ' + entry.value);
//           console.log('Entry done? ' + entry.done);
//         }
//         return entry;
//       });
//     });

//     return fetchEvents.then(function() {
//       console.log(events);
//       res.send('[' + events.join(',') + ']');
//       // res.json(events);
//     });
//   });
// });

// // Loop through iterator until all elements have been retrieved
// function iteratorLoop(it, promise, fn) {
//   return promise.then(fn).then(function (entry) {
//     return !entry.done ? iteratorLoop(it, it.next(), fn) : entry;
//   });
// }

app.post('/events', function (req, res) {
  // console.log('POST on /events: ' + JSON.stringify(req.body));
  // console.log('Title: ' + req.body.title);
  // console.log(req.headers);
  console.log(req.body);
  var event = req.body;
  var eventId = newEventId();
  store.then(function(client) {
    client.putIfAbsent(eventId, event).then(function(stored) {
      console.log("Add event: " + stored);
      // TODO: Use res.json()
      res.send('{"succeed":' + stored + '}');
    });
  });
  // console.log(req.title);
  // console.log('Title: ' + req.body.title);
  // res.send('{"succeed":true}');
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
