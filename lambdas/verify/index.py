export const verifyOtp = async (email, otp) => {
  const res = await fetch(`${BASE_URL}/auth/verify`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({ email, otp }),
  });

  return res.json();
};
environment {
  variables = {
    OTP_TABLE   = "otp-table"
    JWT_SECRET  = "mysecret123"
  }
}
