import { useState } from "react";
import { sendOtp } from "../api/api";

export default function Login() {
  const [email, setEmail] = useState("");
  const [loading, setLoading] = useState(false);

  const handleSendOtp = async () => {
    if (!email || !email.includes("@")) {
      alert("Enter valid email");
      return;
    }

    try {
      setLoading(true);

      const res = await sendOtp(email);

      alert(res.message || "OTP sent");

      localStorage.setItem("email", email);

      window.location.href = "/verify";

    } catch (err) {
      alert("Failed to send OTP");
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="h-screen flex items-center justify-center bg-gradient-to-r from-blue-500 to-purple-600">
      <div className="bg-white p-6 rounded-xl shadow-lg w-80">

        <h1 className="text-xl font-bold mb-4 text-center">
          Login
        </h1>

        <input
          className="w-full p-2 border rounded mb-4"
          placeholder="Enter Email"
          onChange={(e) => setEmail(e.target.value)}
        />

        <button
          onClick={handleSendOtp}
          disabled={loading}
          className="w-full bg-blue-600 text-white p-2 rounded hover:bg-blue-700 disabled:opacity-50"
        >
          {loading ? "Sending..." : "Send OTP"}
        </button>

      </div>
    </div>
  );
}
