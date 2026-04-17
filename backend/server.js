require("dotenv").config();

const express = require("express");
const cors = require("cors");

const authRoutes = require("./routes/auth");
const voteRoutes = require("./routes/vote");
const resultRoutes = require("./routes/results");

const app = express();

app.use(cors());
app.use(express.json());

app.use("/auth", authRoutes);
app.use("/vote", voteRoutes);
app.use("/results", resultRoutes);

app.get("/", (req, res) => {
  res.send("RWA Voting Backend Running 🚀");
});

app.listen(5000, () => {
  console.log("Server running on port 5000");
});