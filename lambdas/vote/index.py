export const submitVote = async (data, token) => {
  const res = await fetch(`${BASE_URL}/vote`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${token}`,
    },
    body: JSON.stringify(data),
  });

  return res.json();
};
environment {
  variables = {
    VOTES_TABLE = "votes"
    JWT_SECRET  = "mysecret123"
  }
}
