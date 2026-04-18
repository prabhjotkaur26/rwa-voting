import { useState } from "react";

export default function Dashboard() {
  const [votes] = useState(12450);

  return (
    <div>
      <h1>Dashboard</h1>
      <p>Total Votes: {votes}</p>
    </div>
  );
}
