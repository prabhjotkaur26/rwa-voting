export const verifyOtp = async (mobile, otp) => {
  const res = await fetch(`${BASE_URL}/auth/verify`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({ email, otp }),
  });

  return res.json();
};
