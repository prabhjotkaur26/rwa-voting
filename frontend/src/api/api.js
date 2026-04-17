import axios from "axios";

const API = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL
});

export const sendOTP = (mobile) => API.post("/auth/send-otp", { mobile });
export const verifyOTP = (mobile, otp) => API.post("/auth/verify-otp", { mobile, otp });

export const getElection = () => API.get("/election");
export const getCandidates = (postId) => API.get(`/candidates/${postId}`);
export const submitVote = (data) => API.post("/vote", data);

export const getResults = () => API.get("/results");
