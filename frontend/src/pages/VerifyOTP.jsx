import { useState } from "react";
import { verifyOtp } from "../api/api";

export default function VerifyOtp() {
  const [otp, setOtp] = useState("");

  const handleVerify = async () => {
    const email = localStorage.getItem("email");

    const res = await verifyOtp(email, otp);

    if (res.success) {
      localStorage.setItem("token", res.token);
      window.location.href = "/vote";
    } else {
      alert("Invalid OTP");
    }
  };

  return (
    <div className="h-screen flex items-center justify-center bg-gray-100">
      <div className="bg-white p-6 rounded shadow-lg w-80">
        <h2 className="text-lg font-bold mb-4 text-center">Verify OTP</h2>

        <input
          className="w-full p-2 border rounded mb-4"
          placeholder="Enter OTP"
          onChange={(e) => setOtp(e.target.value)}
        />

        <button
          onClick={handleVerify}
          className="w-full bg-green-600 text-white p-2 rounded"
        >
          Verify
        </button>
      </div>
    </div>
  );
}
