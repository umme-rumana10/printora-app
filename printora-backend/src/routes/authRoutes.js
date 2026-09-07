const express = require("express");

const router = express.Router();

const authController = require("../controllers/authController");

const authMiddleware = require("../middleware/authMiddleware");

router.get("/me", authMiddleware, (req, res) => {
    res.json({
        message: "Protected route success",
        user: req.user
    });
});

router.post("/signup", authController.signUp);

router.post("/login", authController.login);

module.exports = router;