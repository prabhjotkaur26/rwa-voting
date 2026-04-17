import { useState } from "react";
import { motion } from "framer-motion";
import {
  FaVoteYea,
  FaUsers,
  FaChartPie,
  FaSignOutAlt,
} from "react-icons/fa";

export default function Dashboard() {
  const [activeTab, setActiveTab] = useState("vote");

  const candidates = [
    { id: 1, name: "Rahul Sharma", votes: 120, party: "Team A" },
    { id: 2, name: "Priya Verma", votes: 95, party: "Team B" },
    { id: 3, name: "Amit Singh", votes: 80, party: "Team C" },
  ];

  const totalVotes = candidates.reduce((acc, c) => acc + c.votes, 0);

  return (
    <div className="min-h-screen flex bg-gradient-to-br from-black via-[#0f172a] to-[#1e1b4b] text-white">

      {/* SIDEBAR */}
      <div className="w-64 p-6 bg-white/10 backdrop-blur-xl border-r border-white/10">
        <h1 className="text-xl font-bold mb-8">RWA Voting</h1>

        <div className="space-y-4">

          <button
            onClick={() => setActiveTab("vote")}
            className={`flex items-center gap-2 w-full p-2 rounded-lg ${
              activeTab === "vote" ? "bg-indigo-500" : "hover:bg-white/10"
            }`}
          >
            <FaVoteYea /> Vote
          </button>

          <button
            onClick={() => setActiveTab("results")}
            className={`flex items-center gap-2 w-full p-2 rounded-lg ${
              activeTab === "results" ? "bg-indigo-500" : "hover:bg-white/10"
            }`}
          >
            <FaChartPie /> Results
          </button>

          <button className="flex items-center gap-2 w-full p-2 rounded-lg hover:bg-white/10">
            <FaUsers /> Candidates
          </button>

          <button className="flex items-center gap-2 w-full p-2 rounded-lg hover:bg-red-500/20 text-red-300 mt-10">
            <FaSignOutAlt /> Logout
          </button>

        </div>
      </div>

      {/* MAIN AREA */}
      <div className="flex-1 p-8">

        {/* HEADER */}
        <div className="flex justify-between items-center mb-8">
          <h2 className="text-2xl font-bold">Dashboard</h2>

          <div className="px-4 py-2 rounded-xl bg-white/10 border border-white/10">
            Live Election System
          </div>
        </div>

        {/* VOTE TAB */}
        {activeTab === "vote" && (
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">

            {candidates.map((c, i) => (
              <motion.div
                key={c.id}
                initial={{ opacity: 0, y: 30 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: i * 0.1 }}
                className="p-5 rounded-2xl bg-white/10 border border-white/10 backdrop-blur-xl hover:scale-105 transition"
              >
                <h3 className="text-lg font-bold">{c.name}</h3>
                <p className="text-sm text-gray-300">{c.party}</p>

                <div className="mt-4">
                  <div className="w-full h-2 bg-white/10 rounded-full">
                    <div
                      className="h-2 bg-gradient-to-r from-indigo-500 to-purple-500 rounded-full"
                      style={{
                        width: `${(c.votes / totalVotes) * 100}%`,
                      }}
                    />
                  </div>

                  <p className="text-xs mt-2 text-gray-300">
                    {c.votes} votes
                  </p>
                </div>

                <button className="mt-4 w-full p-2 rounded-lg bg-indigo-500 hover:bg-indigo-600 transition">
                  Vote
                </button>
              </motion.div>
            ))}

          </div>
        )}

        {/* RESULTS TAB */}
        {activeTab === "results" && (
          <div className="p-6 rounded-2xl bg-white/10 border border-white/10">
            <h3 className="text-xl font-bold mb-4">Live Results</h3>

            {candidates.map((c) => (
              <div key={c.id} className="mb-4">
                <div className="flex justify-between text-sm">
                  <span>{c.name}</span>
                  <span>{c.votes} votes</span>
                </div>

                <div className="w-full h-2 bg-white/10 rounded-full mt-1">
                  <div
                    className="h-2 bg-green-400 rounded-full"
                    style={{
                      width: `${(c.votes / totalVotes) * 100}%`,
                    }}
                  />
                </div>
              </div>
            ))}
          </div>
        )}

      </div>
    </div>
  );
}
