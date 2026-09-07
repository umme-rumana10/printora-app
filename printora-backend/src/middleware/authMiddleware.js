const supabase = require("../config/supabase");

const authMiddleware = async (req, res, next) => {
    try {
        // 1. Get token from header
        const authHeader = req.headers.authorization;
        if (!authHeader || !authHeader.startsWith("Bearer ")) {

    // Temporary guest mode
    req.user = {
        id: "guest-user",
        email: "guest@printora.com",
        user_metadata: {
            name: "Guest User"
        }
    };

    return next();
}

        const token = authHeader.split(" ")[1];

        // 2. Verify token with Supabase
        const { data, error } = await supabase.auth.getUser(token);

if (error) {
    console.log("SUPABASE AUTH ERROR:", error.message);
}
        if (error || !data?.user) {
            return res.status(401).json({
                message: "Invalid or expired token"
            });
        }

        // 3. Attach user to request
        req.user = data.user;

        next();

    } catch (err) {
        return res.status(500).json({
            message: "Auth middleware error",
            error: err.message
        });
    }
};

module.exports = authMiddleware;