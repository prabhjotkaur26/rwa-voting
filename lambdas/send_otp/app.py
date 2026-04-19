import { BASE_URL } from "../config/api";

export const sendOtp = async (email) => {
  const res = await fetch(`${BASE_URL}/auth/send-otp`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({ email }),
  });

  return res.json();
};
environment {
  variables = {
    OTP_TABLE   = "otp-table"
    JWT_SECRET  = "mysecret123"
  }
}
