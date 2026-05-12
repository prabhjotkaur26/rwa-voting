async function verifyOTP() {

  const otp = document.getElementById("otp").value;

  const email = localStorage.getItem("email");

  try {

    const response = await fetch(
      "https://7p57z2eau2.execute-api.ap-south-1.amazonaws.com/verify-otp",
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json"
        },
        body: JSON.stringify({
          email: email,
          otp: otp
        })
      }
    );

    const data = await response.json();

    console.log(data);

    if (response.ok) {

      alert("OTP Verified Successfully");

      // save JWT token
      localStorage.setItem("token", data.token);

      // redirect
      window.location.href = "vote.html";

    } else {

      alert(data.message || "Verification Failed");
    }

  } catch (error) {

    console.error(error);

    alert("Verification Failed");
  }
}
