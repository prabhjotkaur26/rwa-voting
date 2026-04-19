const { checkLimit } = require("../utils/otpLimiter");

exports.handler = async (event) => {
  const { mobile } = JSON.parse(event.body);

  // 🔐 OTP abuse protection (IMPORTANT)
  await checkLimit(email);

  // 👉 yaha SNS OTP send logic aayega
  console.log("OTP sent to:", email);

  return {
    statusCode: 200,
    body: JSON.stringify({ message: "OTP sent" }),
  };
};
