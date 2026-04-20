import { useState } from "react";
import { sendOtp, verifyOtp } from "./api";

function App() {
  const [email, setEmail] = useState("");
  const [otp, setOtp] = useState("");

  return (
    <div>
      <h1>RWA Voting System</h1>

      <input placeholder="Email" onChange={(e) => setEmail(e.target.value)} />
      <button onClick={() => sendOtp(email)}>Send OTP</button>

      <input placeholder="OTP" onChange={(e) => setOtp(e.target.value)} />
      <button onClick={() => verifyOtp(email, otp)}>Verify</button>
    </div>
  );
}

export default App;
