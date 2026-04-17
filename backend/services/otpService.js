const dynamo = require("./dynamo");

const TABLE = process.env.OTP_TABLE;

// 🔥 Generate OTP
function generateOTP() {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

// 🔥 Save OTP with TTL
async function saveOTP(mobileNumber, otp) {
  const expiresAt = Math.floor(Date.now() / 1000) + 300; // 5 min

  await dynamo.put({
    TableName: TABLE,
    Item: {
      mobileNumber,
      otp,
      expiresAt,
      used: false
    }
  }).promise();
}

// 🔥 Verify OTP
async function verifyOTP(mobileNumber, otp) {
  const data = await dynamo.get({
    TableName: TABLE,
    Key: { mobileNumber }
  }).promise();

  if (!data.Item) return false;

  if (data.Item.used) return false;

  if (data.Item.otp !== otp) return false;

  // mark used
  await dynamo.update({
    TableName: TABLE,
    Key: { mobileNumber },
    UpdateExpression: "SET used = :u",
    ExpressionAttributeValues: { ":u": true }
  }).promise();

  return true;
}

module.exports = { generateOTP, saveOTP, verifyOTP };