import { useState } from "react";
import { motion } from "framer-motion";
import { sendOtp } from "../api/api";

export default function Login() {
  const [email, setEmail] = useState("");

  const handleSendOtp = async () => {
    if (!email) return alert("Enter email");

    const res = await sendOtp(email);
    alert(res.message);
    localStorage.setItem("email", email);
    window.location.href = "/verify";
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-[#0f172a] via-[#1e1b4b] to-[#312e81]">

      <motion.div
        initial={{ opacity: 0, scale: 0.9 }}
        animate={{ opacity: 1, scale: 1 }}
        className="w-[380px] p-8 rounded-2xl backdrop-blur-xl bg-white/10 border border-white/20 shadow-2xl"
      >

        <h1 className="text-white text-2xl font-bold text-center mb-2">
          OTP Secure Voting
        </h1>

        <p className="text-gray-300 text-sm text-center mb-6">
          Enter your email to continue voting
        </p>

        <input
          type="email"
          placeholder="Enter Email"
          className="w-full p-3 rounded-xl bg-white/10 text-white border border-white/20 focus:outline-none focus:ring-2 focus:ring-indigo-500"
          onChange={(e) => setEmail(e.target.value)}
        />

        <button
          onClick={handleSendOtp}
          className="w-full mt-5 p-3 rounded-xl bg-gradient-to-r from-indigo-500 to-purple-500 text-white font-semibold hover:scale-105 transition"
        >
          Send OTP
        </button>

        <p className="text-xs text-gray-400 text-center mt-4">
          Secure • Transparent • RWA Voting System
        </p>

      </motion.div>
    </div>
  );
}
