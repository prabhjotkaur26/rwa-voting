import { useState } from "react";
import { sendOtp } from "../api/api";

export default function Login() {
  const [email, setEmail] = useState("");

  const handleSendOtp = async () => {
    const res = await sendOtp(email);
    alert(res.message);
    localStorage.setItem("email", email);
    window.location.href = "/verify";
  };

  return (
    <div className="h-screen flex items-center justify-center bg-gradient-to-r from-blue-500 to-purple-600">
      <div className="bg-white p-6 rounded-xl shadow-lg w-80">
        <h1 className="text-xl font-bold mb-4 text-center">Login</h1>

        <input
          className="w-full p-2 border rounded mb-4"
          placeholder="Enter Email"
          onChange={(e) => setEmail(e.target.value)}
        />

        <button
          onClick={handleSendOtp}
          className="w-full bg-blue-600 text-white p-2 rounded hover:bg-blue-700"
        >
          Send OTP
        </button>
      </div>
    </div>
  );
}
