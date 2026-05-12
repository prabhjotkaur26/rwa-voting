async function sendOTP() {

  const email = document.getElementById("email").value;

  try {

    const response = await fetch(
      "https://7p57z2eau2.execute-api.ap-south-1.amazonaws.com/send-otp",
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json"
        },
        body: JSON.stringify({ email })
      }
    );

    const data = await response.json();

    console.log(data);

    alert(data.message);

    if (response.ok) {

      localStorage.setItem("email", email);

      // IMPORTANT FIX
      window.location.href = "verify.html";
    }

  } catch (error) {

    console.error(error);

    alert("Request Failed");
  }
}
