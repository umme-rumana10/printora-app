const express = require("express");
const cors = require("cors");

const authRoutes = require("./routes/authRoutes");

const kioskRoutes = require("./routes/kiosk.routes");

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// Test Route
app.get("/", (req, res) => {
    res.send("🚀 Printora Backend Running");
});

// Health Check Route
app.get("/health", (req, res) => {
    res.status(200).json({
        status: "OK",
        service: "Printora Backend",
        timestamp: new Date().toISOString()
    });
});

//print routes
const printRoutes = require("./routes/printRoutes");

app.use("/api/print", printRoutes);

// Kiosk Routes
app.use("/api/kiosk", kioskRoutes);

// Auth Routes
app.use("/api/auth", authRoutes);

module.exports = app;