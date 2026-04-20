import AWS from "aws-sdk";
import { response } from "../shared/response.js";

const ses = new AWS.SES();
const db = new AWS.DynamoDB.DocumentClient();

export const handler = async (event) => {

  const { email } = JSON.parse(event.body);
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
    Source: "your_verified_email@gmail.com",
    Destination: { ToAddresses: [email] },
    Message: {
      Subject: { Data: "RWA Voting OTP" },
      Body: { Text: { Data: `Your OTP is ${otp}` } }
    }
  }).promise();

  return response(200, { message: "OTP sent" });
};
