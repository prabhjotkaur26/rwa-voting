const jwt = require("jsonwebtoken");

exports.handler = async (event) => {
  const { refreshToken } = JSON.parse(event.body);

  const decoded = jwt.verify(refreshToken, process.env.JWT_SECRET);

  const newAccessToken = jwt.sign(
    { mobile: decoded.mobile, role: decoded.role },
    process.env.JWT_SECRET,
    { expiresIn: "15m" }
  );

  return {
    statusCode: 200,
    body: JSON.stringify({ accessToken: newAccessToken }),
  };
};
