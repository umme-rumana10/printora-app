const express = require("express");
const router = express.Router();

const authMiddleware = require("../middleware/authMiddleware");
const upload = require("../middleware/uploadMiddleware");
const printController = require("../controllers/printController");

console.log("authMiddleware:", authMiddleware);
console.log("upload:", upload);
console.log("uploadPrintFile:", printController.uploadPrintFile);
console.log("uploadMultipleFiles:", printController.uploadMultipleFiles);

router.post(
  "/upload",
  upload.single("file"),
  printController.uploadPrintFile
);

router.post(
  "/upload-multiple",
  upload.array("files"),
  printController.uploadMultipleFiles
);

router.get(
    "/order/:orderId",
    printController.getOrder
);

router.get(
    "/order/:orderId",
    printController.getOrder
);

// Get all queued jobs
router.get(
    "/jobs/queued",
    printController.getQueuedJobs
);

// Update status of a job
router.patch(
    "/jobs/:jobId/status",
    printController.updateJobStatus
);

module.exports = router;

