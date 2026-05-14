async function loadResults() {

  const table = document.getElementById("resultsTable");

  try {

    const response = await fetch(
      "https://7p57z2eau2.execute-api.ap-south-1.amazonaws.com/results"
    );

    const data = await response.json();

    const orderedMembers = [
      "President",
      "Vice President",
      "Secretary ",
      "Treasurer",
      "Member 5",
      "Member 6",
      "Member 7",
      "Member 8",
      "Member 9"
    ];

    orderedMembers.forEach(member => {

      if (data[member]) {

        table.innerHTML += `
          <tr>
            <td>${member}</td>
            <td>${data[member]}</td>
          </tr>
        `;
      }
    });

  } catch (error) {

    console.error(error);

    alert("Failed to load results");
  }
}

loadResults();
