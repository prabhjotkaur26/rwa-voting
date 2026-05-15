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

    document.getElementById("totalVotes").innerText = totalVotes;

    const totalVoters = 150;

    document.getElementById("totalVoters").innerText = totalVoters;

    const participation =
      ((totalVotes / totalVoters) * 100).toFixed(1);

    document.getElementById("participation").innerText =
      participation + "%";

    updateChart(data);

  } catch (error) {

    console.error(error);
  }
}
