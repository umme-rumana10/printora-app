const { print } = require("pdf-to-printer");

async function printFile(filePath) {

    try {

        console.log("[Printer] Sending file to printer...");

        await print(filePath);

        console.log("[Printer] Print command sent successfully.");

        return {
            success: true
        };

    } catch (err) {

        console.error("[Printer] Error:", err.message);

        return {
            success: false,
            reason: err.message
        };

    }

}

module.exports = {
    printFile
};