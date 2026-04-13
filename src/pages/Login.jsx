import { useState } from "react";
import { useNavigate } from "react-router-dom";

export default function Login() {
  const [mobileNumber, setMobileNumber] = useState("");
  const [otp, setOtp] = useState("");
  const [step, setStep] = useState(1); // 1 = send otp, 2 = verify otp

  const navigate = useNavigate();

  // 📤 SEND OTP
  const sendOTP = async () => {
    if (!mobileNumber) return alert("Enter mobile number");

    try {
      const res = await fetch("http://localhost:5000/auth/send-otp", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ mobileNumber })
      });

      const data = await res.json();
      alert(data.message || "OTP sent");
      setStep(2);

    } catch (err) {
      alert("Error sending OTP");
    }
  };

  // 🔐 VERIFY OTP
  const verifyOTP = async () => {
    if (!otp) return alert("Enter OTP");

    try {
      const res = await fetch("http://localhost:5000/auth/verify-otp", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ mobileNumber, otp })
      });

      const data = await res.json();

      if (!res.ok) {
        return alert(data.message || "Invalid OTP");
      }

      // store session
      localStorage.setItem("token", data.token);

      alert("Login successful ✅");
      navigate("/vote");

    } catch (err) {
      alert("Server error");
    }
  };

  return (
    <div style={styles.container}>
      <div style={styles.card}>
        <h2>🗳️ OTP Secure Voting Login</h2>

        {/* STEP 1: MOBILE INPUT */}
        {step === 1 && (
          <>
            <input
              placeholder="Enter Mobile Number"
              style={styles.input}
              onChange={(e) => setMobileNumber(e.target.value)}
            />

            <button style={styles.button} onClick={sendOTP}>
              Send OTP
            </button>
          </>
        )}

        {/* STEP 2: OTP INPUT */}
        {step === 2 && (
          <>
            <input
              placeholder="Enter OTP"
              style={styles.input}
              onChange={(e) => setOtp(e.target.value)}
            />

            <button style={styles.button} onClick={verifyOTP}>
              Verify & Login
            </button>
          </>
        )}
      </div>
    </div>
  );
}

const styles = {
  container: {
    display: "flex",
    justifyContent: "center",
    alignItems: "center",
    height: "80vh"
  },
  card: {
    background: "white",
    padding: 30,
    borderRadius: 12,
    boxShadow: "0 4px 15px rgba(0,0,0,0.1)",
    textAlign: "center",
    width: 300
  },
  input: {
    padding: 10,
    width: "100%",
    marginTop: 10,
    marginBottom: 10
  },
  button: {
    background: "#4f46e5",
    color: "white",
    padding: 10,
    border: "none",
    width: "100%",
    borderRadius: 6,
    cursor: "pointer"
  }
};