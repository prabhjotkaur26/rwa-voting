import { BrowserRouter, Routes, Route } from "react-router-dom";
import Login from "./pages/Login";
import VerifyOtp from "./pages/VerifyOtp";
import Vote from "./pages/Vote";
import VotingDashboard from "./pages/VotingDashboard";
import Layout from "./components/Layout";

function App() {
  return (
    <BrowserRouter>
      <Layout>
        <Routes>
          <Route path="/" element={<Login />} />
          <Route path="/verify" element={<VerifyOtp />} />
          <Route path="/vote" element={<Vote />} />
          <Route path="/admin" element={<VotingDashboard />} />
        </Routes>
      </Layout>
    </BrowserRouter>
  );
}

export default App;
