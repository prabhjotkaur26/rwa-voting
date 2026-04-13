const express = require("express");
const AWS = require("aws-sdk");
const router = express.Router();

const dynamo = new AWS.DynamoDB.DocumentClient();
const TABLE = "rwa-voting-votes3";

router.get("/:electionId/:postId", async (req, res) => {
  try {
    const { electionId, postId } = req.params;

    const data = await dynamo.query({
      TableName: TABLE,
      KeyConditionExpression: "PK = :pk",
      ExpressionAttributeValues: {
        ":pk": `${electionId}#${postId}`
      }
    }).promise();

    // aggregate
    const result = {};

    data.Items.forEach(item => {
      result[item.candidateId] = (result[item.candidateId] || 0) + 1;
    });

    res.json(result);

  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;