exports.handler = (event, context, callback) => {
    console.log(`TEST: ${event.queryStringParameters["name"]}`)
    callback(null, {
        statusCode: '200',
        body: 'Hello World'
    });
    // callback(null, {
    //     statusCode: '200',
    //     body: 'Hello ' + event.queryStringParameters["name"] + '!'
    // });
};