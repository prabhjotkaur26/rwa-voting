import AWS from "aws-sdk";

const ses = new AWS.SES();
const db = new AWS.DynamoDB.DocumentClient();

export const handler = async (event) => {
  try {

    const { email } = JSON.parse(event.body);

    if (!email) {
      return {
        statusCode: 400,
        body: JSON.stringify({ message: "Email required" })
      };
    }

    const otp = Math.floor(100000 + Math.random() * 900000);

    await db.put({
      TableName: "OTP_TABLE",
      Item: {
        email,
        otp,
        ttl: Math.floor(Date.now()/1000) + 300
      }
    }).promise();

    await ses.sendEmail({
      Source: "prabh008968@gmail.com",
      Destination: { ToAddresses: [email] },
      Message: {
        Subject: { Data: "RWA Voting OTP" },
        Body: {
          Text: { Data: `Your OTP is ${otp}` }
        }
      }
    }).promise();

    return {
      statusCode: 200,
      headers: {
        "Access-Control-Allow-Origin": "*"
      },
      body: JSON.stringify({ message: "OTP sent successfully" })
    };

  } catch (error) {
    console.log("OTP ERROR:", error);

    return {
      statusCode: 500,
      body: JSON.stringify({
        message: "OTP failed",
        error: error.message
      })
    };
  }
};
