const path = require("path");
const supabase = require("../config/supabase");

const uploadFile = async (file, userId) => {

    const extension = path.extname(file.originalname);

    const fileName =
        `${userId}-${Date.now()}-${Math.random()
            .toString(36)
            .substring(2, 8)}${extension}`;

    const { error } = await supabase
        .storage
        .from("printora-files")
        .upload(fileName, file.buffer, {
            contentType: file.mimetype
        });

    if (error) throw error;

    const { data } = supabase
        .storage
        .from("printora-files")
        .getPublicUrl(fileName);

    return {
        fileName,
        url: data.publicUrl
    };
};

module.exports = { uploadFile };