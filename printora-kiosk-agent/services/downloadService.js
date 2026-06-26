const axios = require("axios");
const fs = require("fs");
const path = require("path");

async function downloadFile(fileUrl, fileName) {

    const downloadsFolder = path.join(__dirname, "../downloads");

    if (!fs.existsSync(downloadsFolder)) {
        fs.mkdirSync(downloadsFolder);
    }

    const filePath = path.join(downloadsFolder, fileName);

    const response = await axios({
        url: fileUrl,
        method: "GET",
        responseType: "stream"
    });

    const writer = fs.createWriteStream(filePath);

    response.data.pipe(writer);

    return new Promise((resolve, reject) => {

        writer.on("finish", () => resolve(filePath));

        writer.on("error", reject);

    });

}

module.exports = {
    downloadFile
};