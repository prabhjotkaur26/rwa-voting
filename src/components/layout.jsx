import { Link } from "react-router-dom";
import { FaVoteYea, FaChartBar, FaHome } from "react-icons/fa";

export default function Layout({ children }) {
  return (
    <div style={styles.app}>

      {/* Sidebar */}
      <div style={styles.sidebar}>
        <h2 style={styles.logo}>🗳️ RWA Vote</h2>

        <Link to="/" style={styles.link}>
          <FaHome /> Login
        </Link>

        <Link to="/vote" style={styles.link}>
          <FaVoteYea /> Vote
        </Link>

        <Link to="/results" style={styles.link}>
          <FaChartBar /> Results
        </Link>

        <Link to="/dashboard" style={styles.link}>
          📊 Dashboard
        </Link>
      </div>

      {/* Main content */}
      <div style={styles.main}>
        {children}
      </div>

    </div>
  );
}

const styles = {
  app: {
    display: "flex",
    minHeight: "100vh",
    fontFamily: "Arial",
    background: "#f4f6f9"
  },

  sidebar: {
    width: 220,
    background: "#111827",
    color: "white",
    padding: 20,
    display: "flex",
    flexDirection: "column",
    gap: 15
  },

  logo: {
    marginBottom: 20
  },

  link: {
    color: "white",
    textDecoration: "none",
    padding: 10,
    borderRadius: 6,
    background: "#1f2937"
  },

  main: {
    flex: 1,
    padding: 20
  }
};