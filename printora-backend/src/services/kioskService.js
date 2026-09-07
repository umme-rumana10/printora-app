const { PrismaClient } = require("@prisma/client");
const prisma = new PrismaClient();

const selectBestKiosk = async () => {

    const kiosk = await prisma.kiosk.findFirst({
        where: {
            status: "ACTIVE"
        },
        orderBy: {
            currentLoad: "asc"
        }
    });

    return kiosk;
};

module.exports = { selectBestKiosk };