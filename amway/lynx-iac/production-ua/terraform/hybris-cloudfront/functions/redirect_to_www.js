function handler(event) {
  var request = event.request;
  var host = request.headers.host.value;
  if (!host.startsWith('www') && !host.includes('cloudfront')) {
    var location = 'https://www.'+host+request.uri;
    if(Object.keys(request.querystring).length){
      var str = [];
      for (var p in request.querystring) {
        if (request.querystring.hasOwnProperty(p)) {
          str.push(encodeURIComponent(p) + "=" + encodeURIComponent(request.querystring[p].value));
        }
      }
      location = location + '?' + str.join("&");
    }
    return {
      statusCode: 301,
      statusDescription: 'Redirecting to www domain',
      headers:
        { "location": { "value": location } }
    }
  }
  return request;
}
