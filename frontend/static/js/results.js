async function loadResults() {

  const table = document.getElementById("resultsTable");

  try {

    const response = await fetch(
     "https://7p57z2eau2.execute-api.ap-south-1.amazonaws.com/results"
    );

    const data = await response.json();

    for (let key in data) {

      table.innerHTML += `
        <tr>
          <td>${key}</td>
          <td>${data[key]}</td>
        </tr>
      `;
    }

  } catch (error) {

    console.error(error);

    alert("Failed to load results");
  }
}

loadResults();
