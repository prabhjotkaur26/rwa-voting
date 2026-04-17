import axios from "axios";

const API = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL
});

export const sendOTP = (email) => API.post("/auth/send-otp", { email });
export const verifyOTP = (email, otp) => API.post("/auth/verify-otp", { email, otp });

export const getElection = () => API.get("/election");
export const getCandidates = (postId) => API.get(`/candidates/${postId}`);
export const submitVote = (data) => API.post("/vote", data);

export const getResults = () => API.get("/results");
