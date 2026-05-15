let chart;

async function loadDashboard() {

  try {

    const response = await fetch(
      "https://7p57z2eau2.execute-api.ap-south-1.amazonaws.com/results"
    );

    const data = await response.json();

    console.log(data);

    let totalVotes = 0;

    Object.values(data).forEach(votes => {

      totalVotes += votes;
    });

    const totalVoters = 150;

    document.getElementById("totalVotes").innerText =
      totalVotes;

    document.getElementById("totalVoters").innerText =
      totalVoters;

    document.getElementById("electionStatus").innerText =
      "Active";

    const participation =
      ((totalVotes / totalVoters) * 100).toFixed(1);

    document.getElementById("participation").innerText =
      participation + "%";

    updateChart(data);

  } catch (error) {

    console.error(error);

    alert("Failed to load dashboard");
  }
}

function updateChart(data) {

  const labels = Object.keys(data);

  const votes = Object.values(data);

  const ctx = document
    .getElementById("voteChart")
    .getContext("2d");

  if(chart) {

    chart.destroy();
  }

  chart = new Chart(ctx, {

    type: "bar",

    data: {

      labels: labels,

      datasets: [{

        label: "Votes",

        data: votes,

        borderWidth: 1,

        borderRadius: 10

      }]
    },

    options: {

      responsive: true,

      plugins: {

        legend: {

          display: false
        }
      },

      scales: {

        y: {

          beginAtZero: true
        }
      }
    }
  });
}

loadDashboard();

setInterval(loadDashboard, 3000);
