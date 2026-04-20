import AWS from "aws-sdk";

const db = new AWS.DynamoDB.DocumentClient();

export const handler = async (event) => {

  const { email, otp } = JSON.parse(event.body);

  const data = await db.get({
    TableName: "OTP_TABLE",
    Key: { email }
  }).promise();

  if (!data.Item || data.Item.otp != otp) {
    return {
      statusCode: 401,
      body: JSON.stringify({ message: "Invalid OTP" })
    };
  }

  return {
    statusCode: 200,
    headers: {
    "Access-Control-Allow-Origin": "*"
  },
    body: JSON.stringify({ message: "Login Success" })
  };
};
