const AWS = require("aws-sdk");
const db = new AWS.DynamoDB.DocumentClient();

exports.log = async (action, user) => {
  await db.put({
    TableName: "audit-logs",
    Item: {
      id: Date.now().toString(),
      action,
      user,
      timestamp: new Date().toISOString(),
    },
  }).promise();
};
