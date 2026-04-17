export default function Layout({ children }) {
  return (
    <div>
      <nav className="bg-blue-600 text-white p-4">
        RWA Voting System
      </nav>

      <main>{children}</main>
    </div>
  );
}
