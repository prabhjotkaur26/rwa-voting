from flask import Flask, render_template, request, redirect, session, url_for
import requests

app = Flask(__name__, static_url_path="/static", static_folder="static")
app.secret_key = "supersecretkey"  # Change in production

API_BASE = "https://dksnp4v890.execute-api.ap-south-1.amazonaws.com"  # replace with your API Gateway base URL

@app.route("/")
def home():
    return render_template("login.html")

@app.route("/send-otp", methods=["POST"])
def send_otp():
    email = request.form.get("email")
    if not email:
        return "Email required", 400

    response = requests.post(f"{API_BASE}/send-otp", json={"email": email})
    if response.status_code == 200:
        session["email"] = email
        return render_template("otp.html", email=email)
    else:
        return f"Error: {response.text}", 400

@app.route("/verify-otp", methods=["POST"])
def verify_otp():
    email = request.form.get("email") or session.get("email")
    otp = request.form.get("otp")
    if not email or not otp:
        return "Email and OTP required", 400

    response = requests.post(f"{API_BASE}/verify-otp", json={"email": email, "otp": otp})
    if response.status_code == 200:
        data = response.json()
        token = data.get("token")
        if not token:
            return "Verification failed: missing token", 400

        session["token"] = token
        session["email"] = email
        return redirect(url_for("vote"))
    else:
        return f"Error: {response.text}", 400

@app.route("/vote", methods=["GET", "POST"])
def vote():
    if "token" not in session:
        return redirect(url_for("home"))

    if request.method == "POST":
        candidate = request.form.get("candidate")
        if not candidate:
            return "Candidate required", 400

        headers = {"Authorization": f"Bearer {session['token']}"}
        vote_payload = {
            "email": session["email"],
            "electionId": "election1",
            "votes": {"president": candidate}
        }

        response = requests.post(f"{API_BASE}/vote", json=vote_payload, headers=headers)
        if response.status_code == 200:
            return redirect(url_for("results"))
        else:
            return f"Error: {response.text}", 400

    return render_template("vote.html", email=session.get("email", ""))

@app.route("/results")
def results():
    if "token" not in session:
        return redirect(url_for("home"))

    headers = {"Authorization": f"Bearer {session['token']}"}
    res = requests.get(f"{API_BASE}/results", headers=headers)
    data = res.json() if res.status_code == 200 else {}

    return render_template("results.html", results=data)

@app.route("/logout")
def logout():
    session.clear()
    return redirect(url_for("home"))

if __name__ == "__main__":
    app.run(debug=True)
