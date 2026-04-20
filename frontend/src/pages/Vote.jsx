fetch("https://YOUR_API_GATEWAY/vote", {
  method: "POST",
  headers: {
    "Authorization": token
  },
  body: JSON.stringify({
    voterId,
    candidateId,
    postId
  })
});
