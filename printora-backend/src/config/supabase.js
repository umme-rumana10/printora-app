const { createClient } = require("@supabase/supabase-js");

// IMPORTANT: use SERVICE ROLE for backend
const supabase = createClient(
    process.env.SUPABASE_URL,
    process.env.SUPABASE_SERVICE_ROLE_KEY
);

module.exports = supabase;