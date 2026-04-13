const express = require("express");
const router = express.Router();

const { sendSMS } = require("../services/snsService");
const { generateOTP, saveOTP, verifyOTP } = require("../services/otpService");

// SEND OTP
router.post("/send-otp", async (req, res) => {
  const { mobileNumber } = req.body;

  const otp = generateOTP();

  await saveOTP(mobileNumber, otp);

  await sendSMS(mobileNumber, `Your OTP is ${otp}`);

  res.json({ message: "OTP sent" });
});

// VERIFY OTP
router.post("/verify-otp", async (req, res) => {
  const { mobileNumber, otp } = req.body;

  const valid = await verifyOTP(mobileNumber, otp);

  if (!valid) {
    return res.status(401).json({ message: "Invalid OTP" });
  }

  res.json({
    message: "OTP verified",
    token: mobileNumber // simple token (can upgrade to JWT later)
  });
});

module.exports = router;