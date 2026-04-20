import { API } from "./config/api.js";

export const sendOtp = async (email) => {
  return await fetch(`${API}/send-otp`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ email })
  });
};
export const verifyOtp = (email, otp) =>
  fetch(`${API}/verify-otp`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ email, otp })
  });

export const vote = (data) =>
  fetch(`${API}/vote`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(data)
  });
