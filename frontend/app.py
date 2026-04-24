from flask import Flask, render_template, request, redirect, session
import requests

app = Flask(__name__)
app.secret_key = "supersecretkey"  # Change in production

API_BASE = "https://dksnp4v890.execute-api.ap-south-1.amazonaws.com/"  # replace this

@app.route("/verify-otp", methods=["POST"])
def verify_otp():
    email = request.form.get("email")
    otp = request.form.get("otp")
    if not email or not otp:
        return "Email and OTP required", 400

    response = requests.post(f"{API_BASE}/verify-otp", json={"email": email, "otp": otp})
    if response.status_code == 200:
        data = response.json()
        token = data.get("token")
        # Store token in session (need session)
        session["token"] = token
        session["email"] = email
        return redirect("/vote")
    else:
        return f"Error: {response.text}", 400


@app.route("/vote", methods=["GET", "POST"])
def vote():
    if "token" not in session:
        return redirect("/")

    if request.method == "POST":
        candidate = request.form.get("candidate")
        if not candidate:
            return "Candidate required", 400

        headers = {"Authorization": f"Bearer {session['token']}"}
        response = requests.post(f"{API_BASE}/vote", json={
            "email": session["email"],
            "electionId": "election1",  # hardcoded for now
            "votes": {"president": candidate}
        }, headers=headers)

        if response.status_code == 200:
            return redirect("/results")
        else:
            return f"Error: {response.text}", 400

    return render_template("vote.html")


@app.route("/results")
def results():
    res = requests.get(f"{API_BASE}/results")
    data = res.json()

    return render_template("results.html", results=data)


if __name__ == "__main__":
    app.run(debug=True)