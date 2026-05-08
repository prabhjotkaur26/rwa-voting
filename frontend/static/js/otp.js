function verifyOTP() {

  const otp = document.getElementById("otp").value;

  if (otp.length === 6) {
    alert("OTP Verified");

    window.location.href = "vote.html";
  } else {
    alert("Invalid OTP");
  }
}
