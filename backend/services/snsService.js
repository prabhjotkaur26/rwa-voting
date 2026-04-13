const AWS = require("aws-sdk");
const sns = new AWS.SNS();

async function sendSMS(phone, message) {
  return sns.publish({
    Message: message,
    PhoneNumber: phone
  }).promise();
}

module.exports = { sendSMS };