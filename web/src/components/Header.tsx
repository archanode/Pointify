'use client'

import { useEffect, useState } from 'react'
import { createClient } from '@/lib/supabase/client'
import type { User } from '@supabase/supabase-js'
import Link from 'next/link'

export default function Header(): React.ReactElement {
  const [user, setUser] = useState<User | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    const supabase = createClient()

    const getUser = async (): Promise<void> => {
      const { data: { user } } = await supabase.auth.getUser()
      setUser(user)
      setLoading(false)
    }

    getUser()

    const { data: { subscription } } = supabase.auth.onAuthStateChange((_event, session) => {
      setUser(session?.user ?? null)
    })

    return () => subscription.unsubscribe()
  }, [])

  const handleSignOut = async (): Promise<void> => {
    const supabase = createClient()
    await supabase.auth.signOut()
    window.location.href = '/'
  }

  return (
    <header className="p-4 flex items-center justify-between text-white">
      <Link href="/" className="flex items-center gap-2">
        <div className="w-10 h-10 bg-white rounded-full flex items-center justify-center">
          <span className="text-purple-600 font-bold text-xl">P</span>
        </div>
        <h1 className="text-2xl font-bold">Pointify</h1>
      </Link>

      <nav className="flex items-center gap-4">
        {loading ? (
          <div className="w-8 h-8 border-2 border-white/30 border-t-white rounded-full animate-spin" />
        ) : user ? (
          <>
            <Link
              href="/dashboard"
              className="px-4 py-2 bg-white/20 rounded-lg hover:bg-white/30 transition"
            >
              Dashboard
            </Link>
            <button
              onClick={handleSignOut}
              className="px-4 py-2 bg-white/10 rounded-lg hover:bg-white/20 transition"
            >
              Sign Out
            </button>
          </>
        ) : (
          <>
            <Link
              href="/auth/login"
              className="px-4 py-2 bg-white/20 rounded-lg hover:bg-white/30 transition"
            >
              Login
            </Link>
            <Link
              href="/auth/signup"
              className="px-4 py-2 bg-white rounded-lg text-purple-600 font-semibold hover:bg-white/90 transition"
            >
              Sign Up
            </Link>
          </>
        )}
      </nav>
    </header>
  )
}
