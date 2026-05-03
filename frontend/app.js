const loginView = document.getElementById("login-view");
const otpView = document.getElementById("otp-view");
const voteView = document.getElementById("vote-view");
const resultsView = document.getElementById("results-view");
const messageBox = document.getElementById("message");
const loginForm = document.getElementById("login-form");
const otpForm = document.getElementById("otp-form");
const resultsBody = document.getElementById("results-body");
const resultsEmpty = document.getElementById("results-empty");
const otpDescription = document.getElementById("otp-description");
const voteDescription = document.getElementById("vote-description");

function setMessage(text, type = "info") {
  if (!text) {
    messageBox.style.display = "none";
    messageBox.textContent = "";
    messageBox.className = "";
    return;
  }

  messageBox.style.display = "block";
  messageBox.textContent = text;
  messageBox.className = type === "error" ? "message-error" : "message-info";
}

function showView(view) {
  [loginView, otpView, voteView, resultsView].forEach((section) => {
    section.classList.toggle("active-view", section === view);
  });
  setMessage("");
}

function getStoredEmail() {
  return sessionStorage.getItem("rwaEmail") || "";
}

function getStoredToken() {
  return sessionStorage.getItem("rwaToken") || "";
}

function clearSession() {
  sessionStorage.removeItem("rwaEmail");
  sessionStorage.removeItem("rwaToken");
}

async function postApi(path, payload, token) {
  const headers = {
    "Content-Type": "application/json"
  };

  if (token) {
    headers["Authorization"] = `Bearer ${token}`;
  }

  const response = await fetch(`${API_BASE}${path}`, {
    method: "POST",
    headers,
    body: JSON.stringify(payload)
  });

  const body = await response.json().catch(() => ({}));
  return { status: response.status, body };
}

async function getApi(path, token) {
  const headers = {};
  if (token) {
    headers["Authorization"] = `Bearer ${token}`;
  }

  const response = await fetch(`${API_BASE}${path}`, {
    method: "GET",
    headers
  });

  const body = await response.json().catch(() => ({}));
  return { status: response.status, body };
}

// ✅ LOGIN
async function handleLogin(event) {
  event.preventDefault();

  sessionStorage.clear();

  const email = document.getElementById("login-email").value.trim();
  console.log("Sending email:", email);

  if (!email) {
    setMessage("Please enter your registered email.", "error");
    return;
  }

  try {
    const { status, body } = await postApi("/send-otp", { email });

    if (status === 200) {
      sessionStorage.setItem("rwaEmail", email);
      otpDescription.textContent = `We sent an OTP to ${email}. Enter it below.`;
      showView(otpView);
      setMessage("OTP sent successfully.");
    } else {
      setMessage(body.message || "Unable to send OTP.", "error");
    }
  } catch (error) {
    setMessage(`Network error: ${error.message}`, "error");
  }
}

// ✅ OTP VERIFY
async function handleOtp(event) {
  event.preventDefault();

  const email = getStoredEmail();
  const otp = document.getElementById("otp-code").value.trim();

  if (!email || !otp) {
    setMessage("Email and OTP are required.", "error");
    return;
  }

  try {
    const { status, body } = await postApi("/verify-otp", { email, otp });

    if (status === 200 && body.token) {
      sessionStorage.setItem("rwaToken", body.token);
      voteDescription.textContent = `Logged in as ${email}. Select committee members.`;
      showView(voteView);
      setMessage("OTP verified.");
    } else {
      setMessage(body.message || "OTP verification failed.", "error");
    }
  } catch (error) {
    setMessage(`Network error: ${error.message}`, "error");
  }
}

// ✅ MULTI-MEMBER VOTING (9 MEMBERS)
async function handleVote(event) {
  event.preventDefault();

  const email = getStoredEmail();
  const token = getStoredToken();

  const selected = [];
  document.querySelectorAll('#vote-form input[type="checkbox"]:checked')
    .forEach(cb => selected.push(cb.value));

  if (selected.length === 0) {
    setMessage("Please select at least one member.", "error");
    return;
  }

  try {
    const votePayload = {
      email,
      electionId: "election1",
      votes: {
        committee: selected
      }
    };

    const { status, body } = await postApi("/vote", votePayload, token);

    if (status === 200) {
      await loadResults();
      showView(resultsView);
      setMessage("Vote submitted successfully.");
    } else {
      setMessage(body.message || "Vote failed.", "error");
    }
  } catch (error) {
    setMessage(`Network error: ${error.message}`, "error");
  }
}

// ✅ RESULTS
async function loadResults() {
  const token = getStoredToken();

  if (!token) {
    setMessage("Login required.", "error");
    return;
  }

  const { status, body } = await getApi("/results", token);

  if (status === 200) {
    resultsBody.innerHTML = "";

    const entries = Object.entries(body || {});

    if (entries.length === 0) {
      resultsEmpty.style.display = "block";
      return;
    }

    resultsEmpty.style.display = "none";

    entries.forEach(([key, value]) => {
      const row = document.createElement("tr");
      row.innerHTML = `<td>${key}</td><td>${value}</td>`;
      resultsBody.appendChild(row);
    });
  } else {
    setMessage(body.message || "Unable to load results.", "error");
  }
}

// ✅ LOGOUT
function logout() {
  clearSession();
  showView(loginView);
  setMessage("Logged out.");
}

// ✅ INIT
function init() {
  loginForm.addEventListener("submit", handleLogin);
  otpForm.addEventListener("submit", handleOtp);

  // 🔥 NEW submit button
  document.getElementById("submit-vote").addEventListener("click", handleVote);

  document.getElementById("otp-back").addEventListener("click", (e) => {
    e.preventDefault();
    showView(loginView);
  });

  document.getElementById("vote-logout").addEventListener("click", (e) => {
    e.preventDefault();
    logout();
  });

  document.getElementById("results-back").addEventListener("click", (e) => {
    e.preventDefault();
    showView(voteView);
  });

  document.getElementById("results-logout").addEventListener("click", (e) => {
    e.preventDefault();
    logout();
  });

  const token = getStoredToken();

  if (token) {
    voteDescription.textContent = `Logged in as ${getStoredEmail()}. Select committee members.`;
    showView(voteView);
  } else {
    showView(loginView);
  }
}

window.addEventListener("DOMContentLoaded", init);
