async function loadResults() {

  const table =
    document.getElementById("resultsTable");

  try {

    const response = await fetch(
      "https://7p57z2eau2.execute-api.ap-south-1.amazonaws.com/results"
    );

    const data = await response.json();

    console.log(data);

    table.innerHTML = "";

    Object.keys(data).forEach(member => {

      table.innerHTML += `

        <tr>

          <td>${member}</td>

          <td>${data[member]}</td>

        </tr>
      `;
    });

  } catch (error) {

    console.error(error);

    alert("Failed to load results");
  }
}

loadResults();

setInterval(loadResults, 2000);
