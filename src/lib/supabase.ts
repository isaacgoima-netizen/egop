import { createClient } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseKey = import.meta.env.VITE_SUPABASE_ANON_KEY

let supabase: any = null

if (supabaseUrl && supabaseKey && supabaseUrl !== 'https://your-project.supabase.co') {
  supabase = createClient(supabaseUrl, supabaseKey)
} else {
  console.warn('Supabase not configured. Update .env.local with your credentials.')
  supabase = {
    from: () => ({
      select: () => ({
        limit: () => Promise.resolve({ data: [], error: null })
      })
    })
  }
}

export { supabase }
