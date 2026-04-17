const AWS = require("aws-sdk");

const sns = new AWS.SNS();

async function sendSMS(mobileNumber, otp) {
  if (!mobileNumber.startsWith("+")) {
    mobileNumber = "+" + mobileNumber;
  }

  return sns.publish({
    Message: `Your OTP is ${otp}`,
    PhoneNumber: mobileNumber
  }).promise();
}

module.exports = { sendSMS };