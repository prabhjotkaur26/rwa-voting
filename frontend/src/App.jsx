import { useState } from "react";
import { sendOtp, verifyOtp } from "./api/api";

function App() {
  const [email, setEmail] = useState("");
  const [otp, setOtp] = useState("");
  const [step, setStep] = useState(1); // 1 = send otp, 2 = verify otp

  // 🔥 SEND OTP
  const handleSendOtp = async () => {
    try {
      const res = await sendOtp(email);
      const data = await res.json();

      console.log("OTP Response:", data);
      alert(data.message || "OTP Sent");

      if (res.ok) {
        setStep(2);
      }
    } catch (err) {
      console.error("Send OTP Error:", err);
      alert("Failed to send OTP");
    }
  };

  // 🔐 VERIFY OTP
  const handleVerifyOtp = async () => {
    try {
      const res = await verifyOtp(email, otp);
      const data = await res.json();

      console.log("Verify Response:", data);
      alert(data.message || "Verified");

    } catch (err) {
      console.error("Verify OTP Error:", err);
      alert("OTP verification failed");
    }
  };

  return (
    <div style={{ padding: "20px", fontFamily: "Arial" }}>
      <h1>RWA Voting System</h1>

      {/* 📧 EMAIL INPUT */}
      <input
        type="email"
        placeholder="Enter Email"
        value={email}
        onChange={(e) => setEmail(e.target.value)}
        style={{ padding: "8px", margin: "10px 0", display: "block" }}
      />

      {/* 📩 SEND OTP */}
      {step === 1 && (
        <button onClick={handleSendOtp}>
          Send OTP
        </button>
      )}

      {/* 🔐 OTP INPUT */}
      {step === 2 && (
        <>
          <input
            type="text"
            placeholder="Enter OTP"
            value={otp}
            onChange={(e) => setOtp(e.target.value)}
            style={{ padding: "8px", margin: "10px 0", display: "block" }}
          />

          <button onClick={handleVerifyOtp}>
            Verify OTP
          </button>
        </>
      )}
    </div>
  );
}

export default App;
