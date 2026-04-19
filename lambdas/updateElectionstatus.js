const AWS = require("aws-sdk");
const db = new AWS.DynamoDB.DocumentClient();

exports.handler = async (event) => {
  const { id, status } = JSON.parse(event.body);

  await db.update({
    TableName: "elections",
    Key: { id },
    UpdateExpression: "set #s = :s",
    ExpressionAttributeNames: {
      "#s": "status",
    },
    ExpressionAttributeValues: {
      ":s": status,
    },
  }).promise();

  return {
    statusCode: 200,
    body: JSON.stringify({ message: "Status updated" }),
  };
};
