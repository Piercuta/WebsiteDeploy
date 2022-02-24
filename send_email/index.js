var AWS = require('aws-sdk');
    // Set the region 
    AWS.config.update({region: 'eu-west-1'});

exports.handler = async (event) => {
    
    console.log(event);
    // Create sendEmail params 
    var params = {
      Destination: { /* required */
        ToAddresses: [
          'pierre.courteille@gmail.com',
          /* more items */
        ]
      },
      Message: { /* required */
        Body: { /* required */
          Html: {
           Charset: "UTF-8",
           Data: 'name : ' + event.name +  '<br> email : ' +event.email + '<br> message : ' +event.message
          }
          
         },
         Subject: {
          Charset: 'UTF-8',
          Data: event.subject
         }
        },
      Source: 'pcourteille@premaccess.com', /* required */
      
    };
    
    // Create the promise and SES service object
    var sendPromise = new AWS.SES({apiVersion: '2010-12-01'}).sendEmail(params).promise();
    
    // Handle promise's fulfilled/rejected states
    var res = await sendPromise;
    console.log(res);

    
    
    
    // TODO implement
    const response = {
        statusCode: 200,
        header: {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
        },
        body: JSON.stringify('Hello from Lambda!'),
    };
    return response;
};
