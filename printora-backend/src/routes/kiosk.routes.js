const express = require("express");
const router = express.Router();

const kioskController = require("../controllers/kioskController");

router.get("/", kioskController.getAllKiosks);

// Get jobs
router.get("/:kioskId/jobs", kioskController.getKioskJobs);

// Start printing
router.patch("/print/:jobId/start", kioskController.startPrinting);

// Complete printing
router.patch("/print/:jobId/complete", kioskController.completePrint);

module.exports = router;