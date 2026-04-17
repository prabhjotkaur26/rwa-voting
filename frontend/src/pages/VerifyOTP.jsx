import { useState } from "react";
import { verifyOTP } from "../api/api";
import { useNavigate } from "react-router-dom";

export default function OTPVerify() {
  const [otp, setOtp] = useState("");
  const navigate = useNavigate();

  const handleVerify = async () => {
    const email = localStorage.getItem("email");
    const res = await verifyOTP(email, otp);

    localStorage.setItem("token", res.data.token);
    navigate("/dashboard");
  };

  return (
    <div className="h-screen flex items-center justify-center">
      <div className="bg-white p-6 rounded shadow w-80">
        <h2 className="text-xl font-semibold mb-3">Enter OTP</h2>
        <input
          className="w-full border p-2"
          onChange={(e) => setOtp(e.target.value)}
        />
        <button
          className="w-full mt-3 bg-green-600 text-white p-2 rounded"
          onClick={handleVerify}
        >
          Verify
        </button>
      </div>
    </div>
  );
}
