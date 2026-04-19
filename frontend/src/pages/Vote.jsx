fetch(`${API_BASE_URL}/vote`, {
  method: "POST",
  headers: {
    "Content-Type": "application/json"
  },
  body: JSON.stringify({ candidateId })
});
