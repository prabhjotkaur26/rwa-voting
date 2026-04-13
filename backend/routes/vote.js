const express = require("express");
const AWS = require("aws-sdk");
const router = express.Router();

const dynamo = new AWS.DynamoDB.DocumentClient();
const TABLE = "rwa-voting-votes3";

router.post("/", async (req, res) => {
  try {
    const { electionId, postId, candidateId, mobileNumber } = req.body;

    if (!electionId || !postId || !candidateId || !mobileNumber) {
      return res.status(400).json({ message: "Missing fields" });
    }

    await dynamo.put({
      TableName: TABLE,
      Item: {
        PK: `${electionId}#${postId}`,
        SK: mobileNumber,
        candidateId,
        timestamp: Date.now()
      },
      ConditionExpression: "attribute_not_exists(SK)"
    }).promise();

    res.json({ message: "Vote recorded" });

  } catch (err) {
    if (err.code === "ConditionalCheckFailedException") {
      return res.status(409).json({ message: "Already voted" });
    }

    res.status(500).json({ error: err.message });
  }
});

module.exports = router;