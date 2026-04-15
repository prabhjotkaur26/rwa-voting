import jwt

SECRET = os.environ['JWT_SECRET']

token = jwt.encode(
    {"email": email, "exp": int(time.time()) + 3600},
    SECRET,
    algorithm="HS256"
)
