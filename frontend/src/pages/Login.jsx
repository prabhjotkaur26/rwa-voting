import { useState } from "react";
import { sendOtp, verifyOtp } from "../api/api.js";

export default function Login() {
  const [email, setEmail] = useState("");
  const [otp, setOtp] = useState("");
  const [step, setStep] = useState(1);
  const [loading, setLoading] = useState(false);

  const handleSendOtp = async () => {
    try {
      setLoading(true);
      await sendOtp(email);
      alert("OTP sent to your email");
      setStep(2);
    } catch (err) {
      alert("Failed to send OTP");
    } finally {
      setLoading(false);
    }
  };

  const handleVerifyOtp = async () => {
    try {
      setLoading(true);
      const res = await verifyOtp(email, otp);

      // Save token
      localStorage.setItem("token", res.data.token);

      alert("Login successful ✅");

      // redirect
      window.location.href = "/vote";

    } catch (err) {
      alert("Invalid OTP ❌");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="flex items-center justify-center h-screen bg-gray-100">
      <div className="bg-white p-6 rounded shadow w-80">

        <h2 className="text-xl font-bold mb-4 text-center">
          Voter Login
        </h2>

        {step === 1 && (
          <>
            <input
              type="email"
              placeholder="Enter email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              className="w-full p-2 border mb-3"
            />

            <button
              onClick={handleSendOtp}
              className="w-full bg-blue-500 text-white p-2"
              disabled={loading}
            >
              {loading ? "Sending..." : "Send OTP"}
            </button>
          </>
        )}

        {step === 2 && (
          <>
            <input
              type="text"
              placeholder="Enter OTP"
              value={otp}
              onChange={(e) => setOtp(e.target.value)}
              className="w-full p-2 border mb-3"
            />

            <button
              onClick={handleVerifyOtp}
              className="w-full bg-green-500 text-white p-2"
              disabled={loading}
            >
              {loading ? "Verifying..." : "Verify OTP"}
            </button>
          </>
        )}

      </div>
    </div>
  );
}
