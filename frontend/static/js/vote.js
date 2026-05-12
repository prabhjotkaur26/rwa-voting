async function submitVote() {

  const selected = [];

  document
    .querySelectorAll("input[type='checkbox']:checked")
    .forEach(cb => selected.push(cb.value));

  if (selected.length === 0) {

    alert("Please select at least one candidate");

    return;
  }

  const token = localStorage.getItem("token");

  if (!token) {

    alert("Please login again");

    window.location.href = "login.html";

    return;
  }

  try {

    const response = await fetch(
      "https://7p57z2eau2.execute-api.ap-south-1.amazonaws.com/vote",
      {
        method: "POST",

        headers: {
          "Content-Type": "application/json",
          "Authorization": `Bearer ${token}`
        },

        body: JSON.stringify({

          electionId: "RWA2026",

          votes: {
            committee: selected
          }

        })
      }
    );

    const data = await response.json();

    console.log(data);

    if (response.ok) {

      alert("Vote Submitted Successfully");

      window.location.href = "success.html";

    } else {

      alert(data.message || "Vote submission failed");
    }

  } catch (error) {

    console.error(error);

    alert("Server Error");
  }
}
