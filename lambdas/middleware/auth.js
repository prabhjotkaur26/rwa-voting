import jwt from "jsonwebtoken";

export const verifyToken = (event) => {
    try {
        const authHeader = event.headers?.Authorization || event.headers?.authorization;

        if (!authHeader) {
            throw new Error("No token provided");
        }

        const token = authHeader.split(" ")[1];

        const decoded = jwt.verify(token, process.env.JWT_SECRET);

        return decoded; // contains email
    } catch (err) {
        throw new Error("Unauthorized");
    }
};
