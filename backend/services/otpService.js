const AWS = require("aws-sdk");
const dynamo = new AWS.DynamoDB.DocumentClient();

const TABLE = "rwa-voting-otp";

function generateOTP() {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

async function saveOTP(mobile, otp) {
  return dynamo.put({
    TableName: TABLE,
    Item: {
      mobileNumber: mobile,
      otp,
      expiresAt: Math.floor(Date.now() / 1000) + 300, // 5 min
      used: false
    }
  }).promise();
}

async function verifyOTP(mobile, otp) {
  const data = await dynamo.get({
    TableName: TABLE,
    Key: { mobileNumber: mobile }
  }).promise();

  const item = data.Item;

  if (!item) return false;
  if (item.used) return false;
  if (item.otp !== otp) return false;
  if (item.expiresAt < Math.floor(Date.now() / 1000)) return false;

  // mark as used
  await dynamo.update({
    TableName: TABLE,
    Key: { mobileNumber: mobile },
    UpdateExpression: "set used = :u",
    ExpressionAttributeValues: {
      ":u": true
    }
  }).promise();

  return true;
}

module.exports = { generateOTP, saveOTP, verifyOTP };