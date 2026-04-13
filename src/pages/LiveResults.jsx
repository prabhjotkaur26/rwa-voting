import { useEffect, useState } from "react";

export default function LiveResults() {
  const [data, setData] = useState([]);

  const fetchResults = async () => {
    try {
      const res = await fetch("http://localhost:5000/results");
      const votes = await res.json();

      const countMap = {};

      votes.forEach((v) => {
        const candidate = v.vote;

        if (candidate) {
          countMap[candidate] = (countMap[candidate] || 0) + 1;
        }
      });

      const chartData = Object.keys(countMap).map((key) => ({
        name: key,
        votes: countMap[key]
      }));

      setData(chartData);
    } catch (err) {
      console.log("Error:", err);
    }
  };

  useEffect(() => {
    fetchResults();
    const interval = setInterval(fetchResults, 3000);
    return () => clearInterval(interval);
  }, []);

  return (
    <div style={{ padding: 20 }}>
      <h2>Live Results 🔴</h2>

      {data.length === 0 ? (
        <p>No votes yet</p>
      ) : (
        data.map((item, i) => (
          <div key={i}>
            {item.name} → {item.votes}
          </div>
        ))
      )}
    </div>
  );
}