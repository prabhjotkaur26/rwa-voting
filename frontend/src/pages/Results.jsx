import { useEffect, useState } from "react";
import { API_BASE_URL } from "../config/api";
import { getToken } from "../utils/auth";

export default function Results() {
  const [results, setResults] = useState({});
  const [loading, setLoading] = useState(true);

  // 📥 fetch results
  const fetchResults = async () => {
    try {
      const res = await fetch(`${API_BASE_URL}/results`, {
        headers: {
          Authorization: `Bearer ${getToken()}`
        }
      });

      const data = await res.json();
      setResults(data);
      setLoading(false);
    } catch (err) {
      console.error(err);
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchResults();

    // 🔄 optional live refresh every 5 sec
    const interval = setInterval(fetchResults, 5000);

    return () => clearInterval(interval);
  }, []);

  if (loading) return <h3>Loading results...</h3>;

  return (
    <div style={{ padding: "20px" }}>
      <h2>Live Election Results</h2>

      {Object.keys(results).length === 0 && (
        <p>No votes yet</p>
      )}

      {Object.entries(results).map(([candidate, votes]) => (
        <div
          key={candidate}
          style={{
            margin: "10px 0",
            padding: "10px",
            border: "1px solid #ccc"
          }}
        >
          <h3>{candidate}</h3>
          <p>Votes: {votes}</p>
        </div>
      ))}
    </div>
  );
}
