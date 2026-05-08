async function sendOTP() {

  const email = document.getElementById("email").value;

  if (!email) {
    alert("Please enter email");
    return;
  }

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

    if (response.ok) {

      localStorage.setItem("email", email);

      alert(data.message);

      window.location.href = "/frontend/templates/verify.html";

    } else {

      alert(data.message);
    }

  } catch (error) {

    console.error(error);

    alert("Something went wrong");
  }
}
