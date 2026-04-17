const express = require("express");
const router = express.Router();

const dynamo = require("../services/dynamo");

const TABLE = process.env.VOTES_TABLE;

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

    const result = {};

    data.Items.forEach(item => {
      result[item.candidateId] =
        (result[item.candidateId] || 0) + 1;
    });

    res.json(result);

  } catch (err) {
    res.status(500).json({ message: "Result error" });
  }
});

module.exports = router;