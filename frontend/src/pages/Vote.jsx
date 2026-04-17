export default function Vote() {
  const handleVote = (candidate) => {
    alert(`Voted for ${candidate}`);
  };

  return (
    <div style={{ textAlign: "center", marginTop: "50px" }}>
      <h1>Vote Page</h1>

      <button onClick={() => handleVote("Candidate A")}>
        Candidate A
      </button>

      <br /><br />

      <button onClick={() => handleVote("Candidate B")}>
        Candidate B
      </button>
    </div>
  );
}