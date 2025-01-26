exports.handler = (event, context, callback) => {
    const request = event.Records[0].cf.request;
    const headers = request.headers;
    const origin = request.origin;
    const uri = request.uri;

    var prerenderOrigin = "prerender.amway.ru";
    var hybrisHost = "www.uat.amway.ru";
    if(origin.custom.customHeaders['x-custom-prerender-host']) {
        prerenderOrigin = origin.custom.customHeaders['x-custom-prerender-host'][0].value;
    }
    if(origin.custom.customHeaders['x-custom-hybris-host']) {
        hybrisHost = origin.custom.customHeaders['x-custom-hybris-host'][0].value;
        console.log("Set hybrisHost to: ",hybrisHost);
    }
    
    console.log("Original request origin: ", request.origin);
    console.log("Original request host: ", headers['host'][0].value);
    if (headers['user-agent'] && /googlebot|whatsapp|yandexbot|bingbot|deepcrawl|baiduspider|twitterbot|vkshare/i.test(headers['user-agent'][0].value) && !/\.[a-z]{2,5}($|\?)/i.test(uri)) {
        request.origin = {
            custom: {
                domainName: prerenderOrigin,
                port: 443,
                protocol: 'https',
                path: '',
                sslProtocols: ['TLSv1','TLSv1.1','TLSv1.2'],
                readTimeout: 60,
                keepaliveTimeout: 5,
                customHeaders: {}
            }
        };
        console.log("New request origin: ", request.origin);
    } else {
        console.log(headers['user-agent'][0].value);
        console.log("Origin not changes");
    }
    headers['host'] = [{key: 'host', value: hybrisHost}];
    console.log("New request host: ", headers['host'][0].value);

    callback(null, request);
};
