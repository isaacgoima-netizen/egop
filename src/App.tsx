import * as React from 'react'
import { useEffect, useState } from 'react'
import { supabase } from './lib/supabase'
import './App.css'

export default function App() {
  const [status, setStatus] = useState<'loading' | 'connected' | 'error'>('loading')
  const [error, setError] = useState<string>('')

  useEffect(() => {
    const testConnection = async () => {
      try {
        if (!supabase.from) {
          setStatus('error')
          setError('Supabase not configured')
          return
        }
        const { data, error: err } = await supabase.from('organization').select('id').limit(1)
        if (err) {
          setError(`Database error: ${err.message}`)
          setStatus('error')
        } else {
          setStatus('connected')
        }
      } catch (e) {
        setError(e instanceof Error ? e.message : 'Unknown error')
        setStatus('error')
      }
    }
    testConnection()
  }, [])

  return (
    <div className="container">
      <header>
        <h1>🚀 EGOP - Empower Group Operating Platform</h1>
        <p>Phase 1: Foundation</p>
      </header>

      <section>
        <h2>Status</h2>
        {status === 'loading' && <p>Testing Supabase connection...</p>}
        {status === 'connected' && <p className="success">✓ Supabase connected successfully</p>}
        {status === 'error' && <p className="error">✗ {error}</p>}
      </section>

      <section>
        <h2>Foundation Setup</h2>
        <p>Phase 1 scaffolding is ready. Next steps:</p>
        <ol>
          <li>Configure .env.local with your Supabase credentials</li>
          <li>Run Supabase migrations in SQL Editor (001-004)</li>
          <li>Begin Phase 2: Business Core (CRM, Projects, Finance)</li>
        </ol>
      </section>

      <section>
        <h2>Architecture</h2>
        <table>
          <tr>
            <th>Layer</th>
            <th>Tech</th>
          </tr>
          <tr>
            <td>Frontend</td>
            <td>React 18 + TypeScript + Vite</td>
          </tr>
          <tr>
            <td>Backend</td>
            <td>Supabase (PostgreSQL + Auth + RLS)</td>
          </tr>
          <tr>
            <td>Deployment</td>
            <td>Vercel (frontend) + Supabase (backend)</td>
          </tr>
        </table>
      </section>
    </div>
  )
}
