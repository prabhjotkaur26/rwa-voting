import { useEffect, useState } from "react";
import { getElection, getCandidates, submitVote } from "../api/api";
import CandidateCard from "../components/CandidateCard";

export default function Dashboard() {
  const [election, setElection] = useState(null);
  const [candidates, setCandidates] = useState([]);
  const [selected, setSelected] = useState({});

  useEffect(() => {
    load();
  }, []);

  const load = async () => {
    const e = await getElection();
    setElection(e.data);

    const c = await getCandidates(e.data.posts[0].id);
    setCandidates(c.data);
  };

  const vote = async () => {
    await submitVote({
      postId: election.posts[0].id,
      candidateId: selected
    });
    alert("Vote submitted successfully");
  };

  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold">Election Dashboard</h1>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mt-4">
        {candidates.map((c) => (
          <CandidateCard
}
