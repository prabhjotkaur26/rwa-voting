import { BrowserRouter, Routes, Route } from "react-router-dom";

import Login from "./pages/Login";
import VerifyOTP from "./pages/VerifyOTP";
import Vote from "./pages/Vote";
import Admin from "./pages/Admin";

export default function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Login />} />
        <Route path="/verify" element={<VerifyOTP />} />
        <Route path="/vote" element={<Vote />} />
        <Route path="/admin" element={<Admin />} />
      </Routes>
    </BrowserRouter>
  );
}