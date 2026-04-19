const jwt = require("jsonwebtoken");

const SECRET = process.env.JWT_SECRET;

exports.handler = async (event) => {
  const { email, role } = JSON.parse(event.body);

  const token = jwt.sign(
    {
      email,
      role, // "voter" | "admin"
    },
    SECRET,
    { expiresIn: "15m" }
  );

  const refreshToken = jwt.sign(
    { email },
    SECRET,
    { expiresIn: "7d" }
  );

  return {
    statusCode: 200,
    body: JSON.stringify({ token, refreshToken }),
  };
};
