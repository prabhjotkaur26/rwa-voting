const BASE_URL = import.meta.env.VITE_API_URL;

export const sendOtp = async (email) => {
  const res = await fetch(`${BASE_URL}/send-otp`, {
    method: "POST",
    body: JSON.stringify({ email }),
  });
  return res.json();
};

export const verifyOtp = async (email, otp) => {
  const res = await fetch(`${BASE_URL}/verify-otp`, {
    method: "POST",
    body: JSON.stringify({ email, otp }),
  });
  return res.json();
};

export const vote = async (data) => {
  const res = await fetch(`${BASE_URL}/vote`, {
    method: "POST",
    body: JSON.stringify(data),
  });
  return res.json();
};
