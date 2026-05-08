async function sendOTP() {

  const email = document.getElementById("email").value;

  localStorage.setItem("email", email);

  alert("OTP Sent Successfully");

  window.location.href = "verify.html";
}
