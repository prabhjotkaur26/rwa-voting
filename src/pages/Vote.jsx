import { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";

const posts = [
  "President",
  "Vice President",
  "Secretary",
  "Treasurer",
  "Member 1",
  "Member 2",
  "Member 3"
];

export default function Vote() {
  const [votes, setVotes] = useState({});
  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();

  const [mobileNumber, setMobileNumber] = useState("");

  // 🔐 AUTH CHECK (UPDATED)
  useEffect(() => {
    const token = localStorage.getItem("token");

    if (!token) {
      navigate("/");
    } else {
      setMobileNumber(token);
    }
  }, [navigate]);

  // 🗳️ select vote
  const handleVote = (post, candidate) => {
    setVotes((prev) => ({
      ...prev,
      [post]: candidate
    }));
  };

  // 🚀 submit vote
  const submitVote = async () => {
    const token = localStorage.getItem("token");

    if (!token) {
      alert("Please login first");
      navigate("/");
      return;
    }

    if (Object.keys(votes).length === 0) {
      alert("Please select votes first");
      return;
    }

    try {
      setLoading(true);

      console.log("Sending to backend:", {
        mobileNumber: token,
        electionId: "e1",
        votes
      });

      const res = await fetch("http://localhost:5000/vote", {
        method: "POST",
        headers: {
          "Content-Type": "application/json"
        },
        body: JSON.stringify({
          mobileNumber: token,
          electionId: "e1",
          votes
        })
      });

      const data = await res.json();

      if (!res.ok) {
        return alert(data.message || "Vote failed");
      }

      localStorage.setItem("votes", JSON.stringify(votes));
      localStorage.setItem("submitted", "true");

      alert(data.message || "Vote submitted successfully ✅");
      navigate("/results");

    } catch (err) {
      console.error("Submit Error:", err);
      alert("Server error. Check backend.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div style={{ padding: 20, fontFamily: "Arial" }}>
      <h2>🗳️ Secure Voting Panel</h2>

      <p style={{ color: "gray" }}>
        Logged in as: {mobileNumber}
      </p>

      {posts.map((post) => (
        <div key={post} style={{ marginBottom: 20 }}>
          <h3>{post}</h3>

          <button onClick={() => handleVote(post, "Candidate A")}>
            Candidate A
          </button>

          <button onClick={() => handleVote(post, "Candidate B")}>
            Candidate B
          </button>

          {votes[post] && (
            <p style={{ color: "green" }}>
              Selected: {votes[post]}
            </p>
          )}
        </div>
      ))}

      <button
        onClick={submitVote}
        disabled={loading}
        style={{
          marginTop: 20,
          padding: 10,
          background: loading ? "gray" : "#4f46e5",
          color: "white",
          border: "none",
          cursor: "pointer"
        }}
      >
        {loading ? "Submitting..." : "Submit Vote"}
      </button>
    </div>
  );
}