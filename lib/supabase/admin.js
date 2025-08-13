import "dotenv/config";

import { createClient as createAdminClient } from "@supabase/supabase-js";

export const createClient = () => {
    return createAdminClient(
        process.env.NEXT_PUBLIC_SUPABASE_URL,
        process.env.SUPABASE_SERVICE_KEY
    );
};
