import { BrowserRouter, Routes, Route, Navigate } from "react-router-dom";

import Login from "./pages/Login";
import Vote from "./pages/Vote";
import Results from "./pages/Results";
import VotingDashboard from "./pages/VotingDashboard";
import Layout from "./components/Layout";

// 🔐 Protected Route Component
function ProtectedRoute({ children }) {
  const token = localStorage.getItem("token");

  if (!token) {
    return <Navigate to="/" replace />;
  }

  return children;
}

export default function App() {
  return (
    <BrowserRouter>
      <Layout>
        <Routes>

          {/* 🔓 Public Route */}
          <Route path="/" element={<Login />} />

          {/* 🔐 Protected Routes */}
          <Route
            path="/vote"
            element={
              <ProtectedRoute>
                <Vote />
              </ProtectedRoute>
            }
          />

          <Route
            path="/results"
            element={
              <ProtectedRoute>
                <Results />
              </ProtectedRoute>
            }
          />

          <Route
            path="/dashboard"
            element={
              <ProtectedRoute>
                <VotingDashboard />
              </ProtectedRoute>
            }
          />

        </Routes>
      </Layout>
    </BrowserRouter>
  );
}