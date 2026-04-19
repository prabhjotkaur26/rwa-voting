const AWS = require("aws-sdk");
const db = new AWS.DynamoDB.DocumentClient();

exports.checkLimit = async (email) => {
  const data = await db.get({
    TableName: "otp-limit",
    Key: { email },
  }).promise();

  if (data.Item && data.Item.count >= 5) {
    throw new Error("OTP limit exceeded");
  }
};
