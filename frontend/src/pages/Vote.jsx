import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import { API_BASE_URL } from "../config/api";
import { getToken } from "../utils/auth";

export default function Vote() {
  const [candidates, setCandidates] = useState([]);
  const [selected, setSelected] = useState("");
  const navigate = useNavigate();

  // 🔐 protect route
  useEffect(() => {
    if (!getToken()) {
      navigate("/login");
    }
  }, []);

  // 📥 fetch candidates (you will connect API later)
  useEffect(() => {
    const fetchCandidates = async () => {
      try {
        const res = await fetch(`${API_BASE_URL}/candidates`, {
          headers: {
            Authorization: `Bearer ${getToken()}`
          }
        });

        const data = await res.json();
        setCandidates(data || []);
      } catch (err) {
        console.error(err);
      }
    };

    fetchCandidates();
  }, []);

  // 🗳️ submit vote
  const submitVote = async () => {
    if (!selected) return alert("Select a candidate");

    try {
      const res = await fetch(`${API_BASE_URL}/vote`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${getToken()}`
        },
        body: JSON.stringify({
          candidateId: selected
        })
      });

      const data = await res.json();

      if (res.ok) {
        alert("Vote submitted successfully");
        navigate("/results");
      } else {
        alert(data.message || "Vote failed");
      }
    } catch (err) {
      console.error(err);
      alert("Server error");
    }
  };

  return (
    <div style={{ padding: "20px" }}>
      <h2>Cast Your Vote</h2>

      {candidates.map((c) => (
        <div key={c.id} style={{ margin: "10px 0" }}>
          <label>
            <input
              type="radio"
              name="candidate"
              value={c.id}
              onChange={() => setSelected(c.id)}
            />
            {c.name}
          </label>
        </div>
      ))}

      <button onClick={submitVote}>
        Submit Vote
      </button>
    </div>
  );
}
