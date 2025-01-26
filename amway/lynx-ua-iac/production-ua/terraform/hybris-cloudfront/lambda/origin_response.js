exports.handler = async (event) => {
  const discard = [ 'JSESSIONID' ];
  const response = event.Records[0].cf.response;
  const uri = event.Records[0].cf.request.uri;
  if (response.status === "200" && /\.(png|svg|jpg|jpeg|gif|css|cssgz|woff)($|\?)/.test(uri)) {
    response.headers['cache-control'] = [{
      key: 'Cache-Control',
      value: 'public, max-age=86400'
    }];
    console.log("CacheControl set to 24h");
    if(response.headers.cookie) {
      const cookies = response.headers.cookie;
      console.log("Response cookies is: ",cookies);
      for(var n = cookies.length; n--;){
        const cval = cookies[n].value.split(/;\ /);
        const vlen = cval.length;
        for (var m = vlen; m--;){
          const cookie_kv = cval[m].split('=')[0];
          if(cookie_kv == discard[0]){
            console.log(">>> Dropping cookie:",cookie_kv);
            cval.splice(m,1);
            break;
          }
        }
        if(cval.length != vlen){
          if(cval.length === 0){
            cookies.splice(n,1); 
          }
          else {
            response.headers.cookie[n].value = cval.join('; '); 
          }
        }
      }
    }
  } else if(response.headers['x-powered-by'] && response.headers['x-powered-by'][0].value === 'Express') {
    response.headers['cache-control'] = [{
      key: 'Cache-Control',
      value: 'private, no-cache'
    }];
    console.log("CacheControl switched off because prerender answer");
  }
  console.log("Response headers: ",response.headers);
  return response;
};
