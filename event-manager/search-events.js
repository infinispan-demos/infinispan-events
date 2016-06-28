// mode=local,language=javascript,parameters=[query],datatype='text/plain; charset=utf-8'

var Collectors = Java.type('java.util.stream.Collectors');

// Case insensitive find
var Pattern = Java.type('java.util.regex.Pattern');
var pattern = Pattern.compile(Pattern.quote(query), Pattern.CASE_INSENSITIVE);

var results = cache.values().stream()
  .sorted(function(e1, e2) {
    var json1 = JSON.parse(e1);
    var json2 = JSON.parse(e2);
    return json1.date.compareTo(json2.date);
  })
  .filter(function(e) {
    return pattern.matcher(e).find();
  })
  .collect(Collectors.toList());

results.toString();
