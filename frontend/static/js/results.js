async function loadResults() {

  const table = document.getElementById("resultsTable");

  const data = {
    "Member 1": 5,
    "Member 2": 4,
    "Member 3": 3
  };

  for (let key in data) {

    table.innerHTML += `
      <tr>
        <td>${key}</td>
        <td>${data[key]}</td>
      </tr>
    `;
  }
  }

loadResults();
