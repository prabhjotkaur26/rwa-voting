const express = require("express");
const router = express.Router();

const dynamo = require("../services/dynamo");

const TABLE = process.env.VOTES_TABLE;

router.post("/", async (req, res) => {
  try {
    const { mobileNumber, electionId, votes } = req.body;

    if (!mobileNumber || !votes || !electionId) {
      return res.status(400).json({ message: "Missing data" });
    }

    for (const postId in votes) {
      const candidateId = votes[postId];

      await dynamo.put({
        TableName: TABLE,
        Item: {
          PK: `${electionId}#${postId}`,
          SK: mobileNumber,
          candidateId
        },
        ConditionExpression: "attribute_not_exists(SK)"
      }).promise();
    }

    res.json({ message: "Vote recorded" });

  } catch (err) {
    if (err.code === "ConditionalCheckFailedException") {
      return res.status(409).json({ message: "Already voted for this post" });
    }

    console.error(err);
    res.status(500).json({ message: "Vote error" });
  }
});

module.exports = router;