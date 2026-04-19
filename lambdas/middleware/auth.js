const jwt = require("jsonwebtoken");

const SECRET = process.env.JWT_SECRET;

exports.verifyToken = (event) => {
  const token = event.headers.Authorization?.replace("Bearer ", "");

  if (!token) throw new Error("No token");

  return jwt.verify(token, SECRET);
};
