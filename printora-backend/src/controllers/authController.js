const supabase = require("../config/supabase");

exports.signUp = async (req, res) => {
    try {
        const { email, password } = req.body;

        if (!email || !password) {
            return res.status(400).json({
                message: "Email and password are required"
            });
        }

        const { data, error } = await supabase.auth.signUp({
            email,
            password
        });

        if (error) {
            return res.status(400).json({
                message: error.message
            });
        }

        return res.status(200).json(data);

    } catch (err) {
        return res.status(500).json({
            message: "Server error",
            error: err.message
        });
    }
};

exports.login = async (req, res) => {
    try {
        console.log("BODY RECEIVED:", req.body); // 🔥 DEBUG LINE

        const { email, password } = req.body;

        if (!email || !password) {
            return res.status(400).json({
                message: "Email and password are required"
            });
        }

        const { data, error } =
            await supabase.auth.signInWithPassword({
                email,
                password
            });

        if (error) {
            return res.status(400).json({
                message: error.message
            });
        }

        return res.status(200).json(data);

    } catch (err) {
        return res.status(500).json({
            message: "Server error",
            error: err.message
        });
    }
};