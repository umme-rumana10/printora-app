const {
    getQueuedJobs,
    updateJobStatus
} = require("../services/apiService");

const {
    downloadFile
} = require("../services/downloadService");

const {
    printFile
} = require("../services/printerService");

const {
    deleteFile
} = require("../services/fileService");

let isPrinting = false;

async function checkQueue() {

    if (isPrinting) {

        console.log("[Scheduler] Printer Busy");
        return;

    }

    isPrinting = true;

    try {

        console.log("\n[Scheduler] Checking Queue...");

        const jobs = await getQueuedJobs();

        if (jobs.length === 0) {

            console.log("[Scheduler] No queued jobs.");
            return;

        }

        const job = jobs[0];

        console.log("[Scheduler] Processing:", job.fileName);

        // Lock the job
        await updateJobStatus(job.id, "DOWNLOADING");

        // ---------------- DOWNLOAD ----------------
        let localPath;

        try {

            localPath = await downloadFile(
                job.fileUrl,
                job.fileName
            );

            console.log("[Download] Saved:", localPath);

        } catch (err) {

            console.error("[Download] Failed:", err.message);

            await updateJobStatus(
                job.id,
                "FAILED"
            );

            return;

        }

        // ---------------- PRINT ----------------

        await updateJobStatus(
            job.id,
            "PRINTING"
        );

        const result = await printFile(localPath);

        if (result.success) {

            await updateJobStatus(
                job.id,
                "READY_FOR_PICKUP"
            );

            await deleteFile(localPath);

            console.log("[Scheduler] Job Completed Successfully");

        } else {

            console.error(
                "[Printer] Failed:",
                result.reason
            );

            await updateJobStatus(
                job.id,
                "FAILED"
            );

        }

    } catch (err) {

        console.error("[Scheduler] Unexpected Error");
        console.error(err);

    } finally {

        isPrinting = false;

    }

}

module.exports = {
    checkQueue
};