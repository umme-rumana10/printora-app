const express = require("express");
const multer = require("multer");

const app = express();

const upload = multer({
    storage: multer.memoryStorage()
});

app.post("/test", upload.single("file"), (req, res) => {
    console.log(req.file);
    console.log(req.body);

    res.json({
        success: true
    });
});

app.listen(3001, () => {
    console.log("Running on port 3001");
});