const { PrismaClient } = require("@prisma/client");

const prisma = new PrismaClient();

// =========================
// Get All Active Kiosks
// =========================

exports.getAllKiosks = async (req, res) => {

    try {

        const kiosks = await prisma.kiosk.findMany({

            where: {
                status: "ACTIVE"
            },

            select: {
                id: true,
                name: true,
                location: true,
                currentLoad: true
            }

        });

        return res.json(kiosks);

    }

    catch (err) {

        return res.status(500).json({

            message: "Error fetching kiosks",

            error: err.message

        });

    }

};

// =========================
// Get Queue for a Kiosk
// =========================

exports.getKioskJobs = async (req, res) => {

    try {

        const { kioskId } = req.params;

        const jobs = await prisma.printJob.findMany({

            where: {

                kioskId,

            },

            include: {

                order: {

                    select: {

                        totalPrice: true

                    }

                }

            },

            orderBy: {

                createdAt: "desc"

            }

        });

        return res.json({

            kioskId,

            queueLength: jobs.length,

            jobs

        });

    }

    catch (err) {

        return res.status(500).json({

            message: "Error fetching queue",

            error: err.message

        });

    }

};

// =========================
// Start Printing
// =========================

exports.startPrinting = async (req, res) => {

    try {

        const { jobId } = req.params;

        const existingJob = await prisma.printJob.findUnique({

            where: {

                id: jobId

            }

        });

        if (!existingJob) {

            return res.status(404).json({

                message: "Job not found"

            });

        }

        if (existingJob.status !== "QUEUED") {

            return res.status(400).json({

                message: "Only QUEUED jobs can start printing"

            });

        }

        const job = await prisma.printJob.update({

            where: {

                id: jobId

            },

            data: {

                status: "PRINTING"

            }

        });

        return res.json({

            message: "Printing started",

            job

        });

    }

    catch (err) {

        return res.status(500).json({

            message: "Error starting print",

            error: err.message

        });

    }

};

// =========================
// Complete Printing
// =========================

exports.completePrint = async (req, res) => {

    try {

        const { jobId } = req.params;

        const existingJob = await prisma.printJob.findUnique({

            where: {

                id: jobId

            }

        });

        if (!existingJob) {

            return res.status(404).json({

                message: "Job not found"

            });

        }

        if (existingJob.status !== "PRINTING") {

            return res.status(400).json({

                message: "Job is not currently printing"

            });

        }

        const result = await prisma.$transaction(async (tx) => {

            const job = await tx.printJob.update({

                where: {

                    id: jobId

                },

                data: {

                    status: "COMPLETED"

                }

            });

            await tx.kiosk.update({

                where: {

                    id: job.kioskId

                },

                data: {

                    currentLoad: {

                        decrement: 1

                    }

                }

            });

            return job;

        });

        return res.json({

            message: "Print completed",

            job: result

        });

    }

    catch (err) {

        return res.status(500).json({

            message: "Error completing print",

            error: err.message

        });

    }

};