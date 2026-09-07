const { uploadFile } = require("../services/storageService");
const { PrismaClient } = require("@prisma/client");

const prisma = new PrismaClient();

// Price Calculation
const calculatePrice = (pages, copies, color) => {
  let base = pages * copies;
  if (color) base *= 2;
  return base * 2;
};

// ================= SINGLE FILE =================

exports.uploadPrintFile = async (req, res) => {

  try {

    const {
      pages,
      copies,
      color,
      kioskId,
      pageRange
    } = req.body;

    if (!req.file) {
      return res.status(400).json({
        message: "No file uploaded"
      });
    }

    const userId = req.user.id;

    // Create user if missing
    const userExists = await prisma.user.findUnique({
      where: {
        id: userId
      }
    });

    if (!userExists) {

      await prisma.user.create({

        data: {

          id: userId,

          email: req.user.email,

          name: req.user.user_metadata?.name || "User"

        }

      });

    }

    // Verify kiosk
    const kiosk = await prisma.kiosk.findUnique({

      where: {

        id: kioskId

      }

    });

    if (!kiosk || kiosk.status !== "ACTIVE") {

      return res.status(400).json({

        message: "Invalid kiosk selected"

      });

    }

    // Upload to Supabase Storage
    const uploadedFile = await uploadFile(req.file, userId);

    // Calculate price
    const price = calculatePrice(

      Number(pages),

      Number(copies),

      color === "true"

    );

    // Create Print Job
    const printJob = await prisma.printJob.create({

      data: {

        userId,

        kioskId: kiosk.id,

        fileName: req.file.originalname,

        fileUrl: uploadedFile.url,

        pages: Number(pages),

        pageRange: pageRange || null,

        copies: Number(copies),

        color: color === "true",

        price,

        status: "QUEUED"

      }

    });

    // Increase kiosk load
    await prisma.kiosk.update({

      where: {

        id: kiosk.id

      },

      data: {

        currentLoad: {

          increment: 1

        }

      }

    });

    return res.json({

      message: "Print job created successfully",

      price,

      printJob

    });

  }

  catch (err) {

    console.log(err);

    return res.status(500).json({

      message: "Upload failed",

      error: err.message

    });

  }

};

// ================= MULTIPLE FILES =================

exports.uploadMultipleFiles = async (req, res) => {
  try {

    console.log("BODY:", req.body);
console.log("FILES:", req.files?.length);
    const userId = "guest-user";
    const { kioskId, settings } = req.body;

    if (!req.files || req.files.length === 0) {
      return res.status(400).json({
        message: "No files uploaded",
      });
    }

    // Create user if missing
    const userExists = await prisma.user.findUnique({
      where: { id: userId },
    });

    if (!userExists) {
      await prisma.user.create({
        data: {
          id: userId,
          email:  "guest@printora.com",
          name: "Guest User",
        },
      });
    }

    // Verify kiosk
    const kiosk = await prisma.kiosk.findUnique({
      where: { id: kioskId },
    });

    if (!kiosk || kiosk.status !== "ACTIVE") {
      return res.status(400).json({
        message: "Invalid kiosk selected",
      });
    }

    const parsedSettings = JSON.parse(settings);

    if (parsedSettings.length !== req.files.length) {
      return res.status(400).json({
        message: "Files and settings count mismatch",
      });
    }

    let totalPrice = 0;
    const uploadedFiles = [];
    

    // -----------------------------
    // Upload all files first
    // -----------------------------
    for (let i = 0; i < req.files.length; i++) {
      const file = req.files[i];
      const option = parsedSettings[i];

      const uploaded = await uploadFile(file, userId);

      const price = calculatePrice(
        Number(option.pages),
        Number(option.copies),
        option.color
      );

      totalPrice += price;

      uploadedFiles.push({
        file,
        option,
        uploaded,
        price,
      });
    }

    // -----------------------------
    // Create Order
    // -----------------------------
    const result = await prisma.$transaction(async (tx) => {

    // Create Order
    const order = await tx.order.create({
        data: {
            userId,
            totalPrice,
            status: "PAID"
        }
    });

    // Create Payment
    await tx.payment.create({
        data: {
            orderId: order.id,
            amount: totalPrice,
            paymentId: null,
            status: "SUCCESS"
        }
    });

    const jobs = [];

    // Create PrintJobs
    for (const item of uploadedFiles) {

        const job = await tx.printJob.create({

            data: {

                orderId: order.id,

                userId,

                kioskId,

                fileName: item.file.originalname,

                fileUrl: item.uploaded.url,

                pages: Number(item.option.pages),

                pageRange: item.option.pageRange || null,

                copies: Number(item.option.copies),

                color: item.option.color,

                price: item.price,

                status: "QUEUED"

            }

        });

        jobs.push(job);
    }

    // Update kiosk load
    await tx.kiosk.update({
        where: {
            id: kioskId
        },
        data: {
            currentLoad: {
                increment: jobs.length
            }
        }
    });

    return {
        order,
        jobs
    };

});

// Return response
return res.json({
    message: "Order created successfully",
    orderId: result.order.id,
    totalPrice,
    jobs: result.jobs
});

} catch (err) {

    console.log(err);

    return res.status(500).json({
      message: "Upload failed",
      error: err.message
    });

  }
};

exports.getOrder = async (req, res) => {

    try {

        const { orderId } = req.params;

        const order = await prisma.order.findUnique({

            where: {
                id: orderId
            },

            include: {

                payment: true,

                printJobs: {

                    select: {

                        id: true,
                        fileName: true,
                        pages: true,
                        copies: true,
                        color: true,
                        price: true,
                        status: true

                    }

                }

            }

        });

        if (!order) {

            return res.status(404).json({

                message: "Order not found"

            });

        }

        return res.json(order);

    }

    catch (err) {

        console.log(err);

        return res.status(500).json({

            message: "Failed to fetch order",

            error: err.message

        });

    }

};

exports.getQueuedJobs = async (req, res) => {

    try {

        const { kioskId } = req.query;

        const jobs = await prisma.printJob.findMany({

            where: {

                status: "QUEUED",

                kioskId: kioskId

            },

            orderBy: {

                createdAt: "asc"

            }

        });

        res.json(jobs);

    } catch (err) {

        res.status(500).json({

            message: err.message

        });

    }

};
// ================= UPDATE JOB STATUS =================

exports.updateJobStatus = async (req, res) => {

    console.log("========== PATCH HIT ==========");
    console.log("PARAMS:", req.params);
    console.log("BODY:", req.body);

    try {

        const { jobId } = req.params;
        const { status } = req.body;

        // Check if status was provided
        if (!status) {
            return res.status(400).json({
                message: "Status is required"
            });
        }

        // Allowed statuses
        const validStatuses = [
            "QUEUED",
            "DOWNLOADING",
            "PRINTING",
            "READY_FOR_PICKUP",
            "FAILED",
            "COLLECTED"
        ];

        // Validate status
        if (!validStatuses.includes(status)) {
            return res.status(400).json({
                message: "Invalid status",
                allowedStatuses: validStatuses
            });
        }

        console.log("STATUS RECEIVED:", status);

        const job = await prisma.printJob.update({
            where: {
                id: jobId
            },
            data: {
                status
            }
        });

        console.log("UPDATED JOB:", job);

        return res.json(job);

    } catch (err) {

        console.error(err);

        return res.status(500).json({
            message: err.message
        });

    }

};