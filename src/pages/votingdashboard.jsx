import { useState, useEffect } from "react";

export default function VotingDashboard() {
  const [votes, setVotes] = useState({});
  const voterId = localStorage.getItem("voterId");

  useEffect(() => {
    const data = JSON.parse(localStorage.getItem("votes")) || {};
    setVotes(data);
  }, []);

  const posts = [
    "President",
    "Vice President",
    "Secretary",
    "Treasurer",
    "Member 1",
    "Member 2",
    "Member 3"
  ];

  return (
    <div style={styles.container}>
      
      {/* Header */}
      <div style={styles.header}>
        <h1>🗳️ RWA Voting Dashboard</h1>
        <p>Welcome, {voterId || "Guest"}</p>
      </div>

      {/* Stats Cards */}
      <div style={styles.cardRow}>
        <div style={styles.card}>
          <h2>{Object.keys(votes).length}</h2>
          <p>Total Votes</p>
        </div>

        <div style={styles.card}>
          <h2>{posts.length}</h2>
          <p>Positions</p>
        </div>

        <div style={styles.card}>
          <h2>Live</h2>
          <p>Status</p>
        </div>
      </div>

      {/* Voting Results */}
      <div style={styles.panel}>
        <h2>📊 Your Votes</h2>

        {Object.keys(votes).length === 0 ? (
          <p>No votes submitted yet</p>
        ) : (
          Object.entries(votes).map(([post, candidate]) => (
            <div key={post} style={styles.row}>
              <span style={styles.post}>{post}</span>
              <span style={styles.candidate}>{candidate}</span>
            </div>
          ))
        )}
      </div>
    </div>
  );
}

/* 🎨 Styles */
const styles = {
  container: {
    padding: 20,
    fontFamily: "Arial",
    background: "#f4f6f9",
    minHeight: "100vh"
  },

  header: {
    background: "#4f46e5",
    color: "white",
    padding: 20,
    borderRadius: 10,
    marginBottom: 20
  },

  cardRow: {
    display: "flex",
    gap: 15,
    marginBottom: 20
  },

  card: {
    flex: 1,
    background: "white",
    padding: 20,
    borderRadius: 10,
    textAlign: "center",
    boxShadow: "0 2px 8px rgba(0,0,0,0.1)"
  },

  panel: {
    background: "white",
    padding: 20,
    borderRadius: 10,
    boxShadow: "0 2px 8px rgba(0,0,0,0.1)"
  },

  row: {
    display: "flex",
    justifyContent: "space-between",
    padding: 10,
    borderBottom: "1px solid #eee"
  },

  post: {
    fontWeight: "bold"
  },

  candidate: {
    color: "#4f46e5"
  }
};