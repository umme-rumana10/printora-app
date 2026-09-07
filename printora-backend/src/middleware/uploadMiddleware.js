const multer = require("multer");

const storage = multer.memoryStorage();

const upload = multer({
    storage,
    limits: {
        files: 20,
        fileSize: 25 * 1024 * 1024
    }
});

module.exports = upload;