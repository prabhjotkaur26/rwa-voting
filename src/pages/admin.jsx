import { useState } from "react";

export default function Admin() {
  const [post, setPost] = useState("");
  const [candidate, setCandidate] = useState("");

  const addCandidate = async () => {
    if (!post || !candidate) {
      alert("Fill all fields");
      return;
    }

    await fetch("http://localhost:5000/admin/add-candidate", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ post, candidate })
    });

    alert("Candidate added!");
    setPost("");
    setCandidate("");
  };

  return (
    <div style={{ padding: 20 }}>
      <h2>Admin Panel</h2>

      <input
        placeholder="Post (e.g. President)"
        value={post}
        onChange={(e) => setPost(e.target.value)}
      />
      <br /><br />

      <input
        placeholder="Candidate Name"
        value={candidate}
        onChange={(e) => setCandidate(e.target.value)}
      />
      <br /><br />

      <button onClick={addCandidate}>
        Add Candidate
      </button>
    </div>
  );
}