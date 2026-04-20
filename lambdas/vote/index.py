import AWS from "aws-sdk";
import { response } from "../shared/response.js";

const db = new AWS.DynamoDB.DocumentClient();

export const handler = async (event) => {

  const { voterId, candidateId, postId } = JSON.parse(event.body);

  await db.put({
    TableName: "VOTES",
    Item: { voterId, candidateId, postId },
    ConditionExpression: "attribute_not_exists(voterId)"
  }).promise();

  return response(200, { message: "Vote Cast Successfully" });
};
