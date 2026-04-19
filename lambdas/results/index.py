export const getResults = async () => {
  const token = localStorage.getItem("token");

  const res = await fetch(`${BASE_URL}/results`, {
    headers: {
      Authorization: `Bearer ${token}`,
    },
  });

  return res.json();
};
