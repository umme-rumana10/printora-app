const fs = require("fs");

async function deleteFile(filePath) {

    try {

        fs.unlinkSync(filePath);

        console.log("[Cleanup] Deleted:", filePath);

    } catch (err) {

        console.error("[Cleanup]", err.message);

    }

}

module.exports = {
    deleteFile
};