import axios from "axios";

const API = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL
});

// Send OTP
export const sendOtp = (email) => {
  return API.post("/auth/send-otp", { email });
};

// Verify OTP
export const verifyOtp = (email, otp) => {
  return API.post("/auth/verify-otp", { email, otp });
};

export default API;
