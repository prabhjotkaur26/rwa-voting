const handleSendOtp = async () => {
  try {
    const res = await sendOtp(email);
    const data = await res.json();
    console.log("OTP Response:", data);
    alert(data.message);
  } catch (err) {
    console.error(err);
    alert("Failed to send OTP");
  }
};
