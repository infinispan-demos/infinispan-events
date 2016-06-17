// mode=local,language=javascript,parameters=[query],datatype='text/plain; charset=utf-8'
var Pattern = Java.type('java.util.regex.Pattern');

var iter = cache.values().iterator();

// Case insensitive find
var pattern = Pattern.compile(Pattern.quote(query), Pattern.CASE_INSENSITIVE);
var results = [];

while (iter.hasNext()) {
  var event = iter.next();
  // if (event.contains(query))
  if (pattern.matcher(event).find())
    results.push(event);
}

print(results);
print(results.length);
results.toString();
