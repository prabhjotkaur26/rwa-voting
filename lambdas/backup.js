const AWS = require("aws-sdk");
const s3 = new AWS.S3();
const db = new AWS.DynamoDB.DocumentClient();

exports.handler = async () => {
  const data = await db.scan({ TableName: "votes" }).promise();

  await s3.putObject({
    Bucket: "rwa-backup-bucket",
    Key: `backup-${Date.now()}.json`,
    Body: JSON.stringify(data.Items),
  }).promise();
};
