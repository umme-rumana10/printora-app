const axios = require("axios");
require("dotenv").config();

const api = axios.create({
    baseURL: process.env.BACKEND_URL
});

async function getQueuedJobs() {

    try {

        const response = await api.get("/api/print/jobs/queued", {
    params: {
        kioskId: process.env.KIOSK_ID
    }
});

        return response.data;

    } catch (err) {

        console.error(err.message);

        return [];

    }

}

async function updateJobStatus(jobId, status) {

    try {

        await api.patch(
            `/api/print/jobs/${jobId}/status`,
            {
                status
            }
        );

        console.log(`Updated ${jobId} -> ${status}`);

    } catch (err) {

        console.error(err.response?.data || err.message);

    }

}

module.exports = {
    getQueuedJobs,
    updateJobStatus
};