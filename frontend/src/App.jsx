import { BrowserRouter, Routes, Route } from "react-router-dom";
import Login from "./pages/Login";
import Vote from "./pages/Vote";

function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Login />} />
        <Route path="/vote" element={<Vote />} />
      </Routes>
    </BrowserRouter>
  );
}

export default App;
