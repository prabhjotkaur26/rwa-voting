import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";

export default function Results() {
  const navigate = useNavigate();

  const [results, setResults] = useState({});
  const [loading, setLoading] = useState(true);

  const mobileNumber = localStorage.getItem("token");

  // 🔐 AUTH CHECK
  useEffect(() => {
    if (!mobileNumber) {
      navigate("/");
      return;
    }

    fetchResults();
    const interval = setInterval(fetchResults, 5000); // polling every 5 sec

    return () => clearInterval(interval);
  }, []);

  // 📊 FETCH RESULTS FROM BACKEND
  const fetchResults = async () => {
    try {
      setLoading(true);

      // ⚠️ change electionId dynamically if needed
      const res = await fetch(
        "http://localhost:5000/results/e1/president"
      );

      const data = await res.json();

      setResults(data || {});
    } catch (err) {
      console.error("Error fetching results:", err);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div style={{ padding: 20 }}>
      <h2>🗳️ Live Election Results</h2>

      <p style={{ color: "gray" }}>
        Logged in as: {mobileNumber}
      </p>

      {loading ? (
        <p>Loading results...</p>
      ) : Object.keys(results).length === 0 ? (
        <p>No results found</p>
      ) : (
        Object.entries(results).map(([candidate, count]) => (
          <div
            key={candidate}
            style={{
              padding: 10,
              marginBottom: 10,
              border: "1px solid #ddd",
              borderRadius: 6
            }}
          >
            <h3>{candidate}</h3>
            <p>Votes: {count}</p>
          </div>
        ))
      )}
    </div>
  );
}