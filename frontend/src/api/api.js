import axios from "axios";

const API = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL
});

// Send OTP
export const sendOtp = (mobile) => {
  return API.post("/auth/send-otp", { mobile });
};

// Verify OTP
export const verifyOtp = (mobile, otp) => {
  return API.post("/auth/verify-otp", { mobile, otp });
};

export default API;
