import { useState } from "react";
import { vote } from "../api/api";

export default function Vote() {
  const [selected, setSelected] = useState("");

  const submitVote = async () => {
    const email = localStorage.getItem("email");

    const res = await vote({
      email,
      post_id: "president",
      candidate_id: selected,
    });

    alert(res.message);
  };

  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold">Vote</h1>

      <div className="mt-4 space-y-2">
        {["A", "B", "C"].map((c) => (
          <div
            key={c}
            onClick={() => setSelected(c)}
            className={`p-3 border rounded cursor-pointer ${
              selected === c ? "bg-blue-200" : ""
            }`}
          >
            Candidate {c}
          </div>
        ))}
      </div>

      <button
        onClick={submitVote}
        className="mt-4 bg-purple-600 text-white p-2 rounded"
      >
        Submit Vote
      </button>
    </div>
  );
}
