import { useState } from "react";
import { sendOTP } from "../api/api";
import { useNavigate } from "react-router-dom";

export default function Login() {
  const [email, setemail] = useState("");
  const navigate = useNavigate();

  const handleSendOTP = async () => {
    await sendOTP(email);
    localStorage.setItem("email", email);
    navigate("/verify");
  };

  return (
    <div className="h-screen flex items-center justify-center bg-gradient-to-r from-indigo-500 to-purple-600">
      <div className="bg-white p-8 rounded-xl shadow-xl w-96">
        <h1 className="text-2xl font-bold mb-4">RWA Voting Login</h1>
        <input
          className="w-full p-2 border rounded"
          placeholder="Enter Email ID"
          onChange={(e) => setMobile(e.target.value)}
        />
        <button
          onClick={handleSendOTP}
          className="w-full mt-4 bg-primary text-white p-2 rounded"
        >
          Send OTP
        </button>
      </div>
    </div>
  );
}
