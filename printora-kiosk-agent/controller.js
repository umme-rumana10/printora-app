require("dotenv").config();

const {
    checkQueue
} = require("./scheduler/printerScheduler");

console.log("🚀 Printora Kiosk Agent Started");

setInterval(async () => {

    try {

        await checkQueue();

    } catch (err) {

        console.error(err);

    }

}, Number(process.env.POLL_INTERVAL));