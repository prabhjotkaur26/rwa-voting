// SEND OTP
fetch("https://YOUR_API_GATEWAY/auth", {
  method: "POST",
  headers: { "Content-Type": "application/json" },
  body: JSON.stringify({ email })
});

// VERIFY OTP
fetch("https://YOUR_API_GATEWAY/verify-otp", {
  method: "POST",
  headers: { "Content-Type": "application/json" },
  body: JSON.stringify({ email, otp })
});
