import { useState } from "react";

export default function Dashboard() {
  const [votes] = useState(12450);

  const candidates = [
    { name: "Alice Johnson", party: "Party A", votes: 5320 },
    { name: "Michael Smith", party: "Party B", votes: 4280 },
    { name: "Sarah Lee", party: "Party C", votes: 3150 },
  ];

  return (
    <div className="min-h-screen bg-slate-100 flex">

      {/* Sidebar */}
      <aside className="w-64 bg-gradient-to-b from-indigo-600 to-purple-700 text-white p-6 hidden md:block">
        <h1 className="text-2xl font-bold mb-8">VoteChain</h1>

        <nav className="space-y-4 text-sm">
          <p className="opacity-80 hover:opacity-100 cursor-pointer">🏠 Dashboard</p>
          <p className="opacity-80 hover:opacity-100 cursor-pointer">🗳 Elections</p>
          <p className="opacity-80 hover:opacity-100 cursor-pointer">📊 Results</p>
          <p className="opacity-80 hover:opacity-100 cursor-pointer">⚙ Settings</p>
        </nav>

        <div className="mt-10 text-xs opacity-70">
          Secure Blockchain Voting System
        </div>
      </aside>

      {/* Main */}
      <main className="flex-1 p-6">

        {/* Top bar */}
        <div className="flex justify-between items-center mb-6">
          <h2 className="text-2xl font-bold text-gray-800">Dashboard</h2>

          <div className="flex items-center gap-3">
            <div className="px-4 py-2 bg-white rounded-full shadow text-sm">
              Balance: 0.25 ETH
            </div>
            <div className="w-10 h-10 rounded-full bg-indigo-500"></div>
          </div>
        </div>

        {/* Stats Cards */}
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">

          <div className="bg-gradient-to-r from-purple-500 to-indigo-500 text-white p-4 rounded-xl shadow">
            <p className="text-sm">Total Votes</p>
            <h3 className="text-2xl font-bold">{votes}</h3>
          </div>

          <div className="bg-white p-4 rounded-xl shadow">
            <p className="text-sm text-gray-500">Active Elections</p>
            <h3 className="text-xl font-bold">3</h3>
          </div>

          <div className="bg-white p-4 rounded-xl shadow">
            <p className="text-sm text-gray-500">Your Status</p>
            <h3 className="text-green-600 font-semibold">Verified Voter</h3>
          </div>

          <div className="bg-white p-4 rounded-xl shadow">
            <p className="text-sm text-gray-500">Next Election</p>
            <h3 className="text-orange-500 font-semibold">In 02h 15m</h3>
          </div>
        </div>

        {/* Content Grid */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">

          {/* Candidates */}
          <div className="lg:col-span-2 bg-white p-5 rounded-xl shadow">
            <h3 className="font-semibold mb-4">Current Elections</h3>

            <div className="grid md:grid-cols-3 gap-4">
              {candidates.map((c, i) => (
                <div
                  key={i}
                  className="border rounded-xl p-4 hover:shadow-lg transition"
                >
                  <div className="w-14 h-14 rounded-full bg-indigo-200 mb-3"></div>

                  <h4 className="font-semibold">{c.name}</h4>
                  <p className="text-sm text-gray-500">{c.party}</p>

                  <div className="mt-3 text-sm">
                    <p className="font-semibold text-indigo-600">
                      {c.votes} Votes
                    </p>
                  </div>

                  <button className="mt-3 w-full bg-indigo-600 text-white py-2 rounded-lg hover:bg-indigo-700 transition">
                    Vote
                  </button>
                </div>
              ))}
            </div>
          </div>

          {/* Right panel */}
          <div className="space-y-6">

            {/* Pie / Stats */}
            <div className="bg-white p-5 rounded-xl shadow">
              <h3 className="font-semibold mb-3">Election Stats</h3>

              <div className="space-y-2 text-sm">
                <p>Total Votes: <b>{votes}</b></p>
                <p>Alice: 43%</p>
                <p>Michael: 34%</p>
                <p>Sarah: 23%</p>
              </div>

              <div className="mt-4 h-2 bg-gray-200 rounded-full overflow-hidden">
                <div className="h-full bg-indigo-500 w-[43%]"></div>
              </div>
            </div>

            {/* Notices */}
            <div className="bg-white p-5 rounded-xl shadow">
              <h3 className="font-semibold mb-3">Important Notices</h3>

              <p className="text-sm text-gray-600 mb-2">
                🔐 Enable 2FA for better security
              </p>
              <p className="text-sm text-gray-600">
                ⏰ Voting ends at 10:00 AM tomorrow
              </p>
            </div>

          </div>
        </div>
      </main>
    </div>
  );
}
