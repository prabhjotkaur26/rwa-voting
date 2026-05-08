async function submitVote() {

  const selected = [];

  document.querySelectorAll("input[type='checkbox']:checked")
    .forEach(cb => selected.push(cb.value));

  console.log(selected);

  alert("Vote Submitted Successfully");

  window.location.href = "success.html";
}
