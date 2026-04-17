import { useEffect, useState } from "react";
import { getResults } from "../api/api";

export default function Results() {
  const [results, setResults] = useState([]);

  useEffect(() => {
    getResults().then((r) => setResults(r.data));
  }, []);

  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold">Election Results</h1>

      {results.map((r) => (
        <div key={r.postId} className="bg-white p-4 shadow rounded mt-3">
          <h2 className="font-semibold">{r.postName}</h2>
          <p>{r.winner}</p>
        </div>
      ))}
    </div>
  );
}
