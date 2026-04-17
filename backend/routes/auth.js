const express = require("express");
const router = express.Router();

const { sendSMS } = require("../services/snsService");
const { generateOTP, saveOTP, verifyOTP } = require("../services/otpService");

// SEND OTP
router.post("/send-otp", async (req, res) => {
  try {
    let { mobileNumber } = req.body;

    if (!mobileNumber) {
      return res.status(400).json({ message: "Mobile required" });
    }

    if (!mobileNumber.startsWith("+")) {
      mobileNumber = "+" + mobileNumber;
    }

    const otp = generateOTP();

    await saveOTP(mobileNumber, otp);
    await sendSMS(mobileNumber, otp);

    res.json({ message: "OTP sent" });

  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Error sending OTP" });
  }
});

// VERIFY OTP
router.post("/verify-otp", async (req, res) => {
  try {
    const { mobileNumber, otp } = req.body;

    const valid = await verifyOTP(mobileNumber, otp);

    if (!valid) {
      return res.status(400).json({ message: "Invalid OTP" });
    }

    res.json({
      message: "OTP verified",
      token: mobileNumber
    });

  } catch (err) {
    res.status(500).json({ message: "Error verifying OTP" });
  }
});

module.exports = router;