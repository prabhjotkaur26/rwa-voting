import { BrowserRouter, Routes, Route } from "react-router-dom";
import Login from "./pages/Login";
import OTPVerify from "./pages/OTPVerify";
import Dashboard from "./pages/Dashboard";
import Admin from "./pages/Admin";
import Results from "./pages/Results";

function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Login />} />
        <Route path="/verify" element={<OTPVerify />} />
        <Route path="/dashboard" element={<Dashboard />} />
        <Route path="/admin" element={<Admin />} />
        <Route path="/results" element={<Results />} />
      </Routes>
    </BrowserRouter>
  );
}

export default App;
