export const handler = async (event) => {

  const token = event.headers.authorization;

  // decode JWT (pseudo logic)
  const decoded = verifyJWT(token);

  return {
    isAuthorized: true,
    context: {
      role: decoded.role   // 👈 THIS IS IMPORTANT
    }
  };
};
