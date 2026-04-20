import { response } from "../shared/response.js";
import AWS from "aws-sdk";

const db = new AWS.DynamoDB.DocumentClient();

export const handler = async (event) => {

  const { email, otp } = JSON.parse(event.body);

  const data = await db.get({
    TableName: "OTP_TABLE",
    Key: { email }
  }).promise();

  if (!data.Item || data.Item.otp != otp) {
    return response(401, { message: "Invalid OTP" });
  }

  return response(200, { message: "Login Success" });
};
