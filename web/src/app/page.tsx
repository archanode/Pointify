'use client'

import { useEffect, useState } from 'react'
import { createClient } from '@/lib/supabase/client'
import type { Database } from '@/types/database'

interface NearbyPoint {
  id: string
  name: string
  description: string | null
  image_url: string | null
  lat: number
  lon: number
  type: 'social' | 'commercial' | 'info' | 'event'
  creator_id: string | null
  posts_count: number
  events_count: number
  distance_km: number
  created_at: string
}

export default function Home(): React.ReactElement {
  const [points, setPoints] = useState<NearbyPoint[]>([])
  const [loading, setLoading] = useState(true)
  const [userLocation, setUserLocation] = useState<{ lat: number; lon: number } | null>(null)

  useEffect(() => {
    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(
        (position) => {
          setUserLocation({
            lat: position.coords.latitude,
            lon: position.coords.longitude,
          })
        },
        () => {
          setUserLocation({ lat: 32.0853, lon: 34.7818 }) // Default: Tel Aviv
        }
      )
    }
  }, [])

  useEffect(() => {
    if (!userLocation) return

    const fetchPoints = async (): Promise<void> => {
      const supabase = createClient()

      const { data, error } = await supabase
        .rpc('get_nearby_points', {
          user_lat: userLocation.lat,
          user_lon: userLocation.lon,
          radius_km: 50,
        })

      if (error) {
        console.error('Error fetching points:', error)
      } else {
        setPoints(data || [])
      }
      setLoading(false)
    }

    fetchPoints()
  }, [userLocation])

  return (
    <main className="min-h-screen bg-gradient-to-b from-purple-600 to-blue-600">
      {/* Header */}
      <header className="p-4 flex items-center justify-between text-white">
        <div className="flex items-center gap-2">
          <div className="w-10 h-10 bg-white rounded-full flex items-center justify-center">
            <span className="text-purple-600 font-bold text-xl">P</span>
          </div>
          <h1 className="text-2xl font-bold">Pointify</h1>
        </div>
        <nav className="flex gap-4">
          <a href="/auth/login" className="px-4 py-2 bg-white/20 rounded-lg hover:bg-white/30 transition">
            Login
          </a>
          <a href="/auth/signup" className="px-4 py-2 bg-white rounded-lg text-purple-600 font-semibold hover:bg-white/90 transition">
            Sign Up
          </a>
        </nav>
      </header>

      {/* Hero */}
      <section className="px-4 py-16 text-center text-white">
        <h2 className="text-5xl font-bold mb-4">Discover Places Around You</h2>
        <p className="text-xl opacity-90 max-w-2xl mx-auto">
          Create and explore geo-tagged points, share posts, and discover events happening near you.
        </p>
      </section>

      {/* Points List */}
      <section className="px-4 pb-16">
        <div className="max-w-4xl mx-auto">
          <h3 className="text-2xl font-bold text-white mb-6">
            {loading ? 'Loading nearby points...' : `${points.length} Points Near You`}
          </h3>

          {loading ? (
            <div className="flex justify-center">
              <div className="w-12 h-12 border-4 border-white/30 border-t-white rounded-full animate-spin" />
            </div>
          ) : points.length === 0 ? (
            <div className="bg-white/10 rounded-2xl p-8 text-center text-white">
              <p className="text-xl mb-4">No points nearby yet!</p>
              <p className="opacity-75">Be the first to create a point in your area.</p>
            </div>
          ) : (
            <div className="grid gap-4 md:grid-cols-2">
              {points.map((point) => (
                <div
                  key={point.id}
                  className="bg-white rounded-2xl p-6 shadow-lg hover:shadow-xl transition"
                >
                  {point.image_url && (
                    <img
                      src={point.image_url}
                      alt={point.name}
                      className="w-full h-40 object-cover rounded-xl mb-4"
                    />
                  )}
                  <h4 className="text-xl font-bold text-gray-800">{point.name}</h4>
                  <p className="text-gray-600 mt-2 line-clamp-2">{point.description}</p>
                  <div className="flex items-center gap-4 mt-4 text-sm text-gray-500">
                    <span>📍 {point.distance_km?.toFixed(1) ?? '?'} km away</span>
                    <span>📝 {point.posts_count} posts</span>
                    <span>📅 {point.events_count} events</span>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </section>

      {/* Features */}
      <section className="bg-white py-16 px-4">
        <div className="max-w-4xl mx-auto">
          <h3 className="text-3xl font-bold text-center text-gray-800 mb-12">
            Available on All Platforms
          </h3>
          <div className="grid md:grid-cols-3 gap-8">
            <div className="text-center">
              <div className="w-16 h-16 bg-purple-100 rounded-2xl flex items-center justify-center mx-auto mb-4">
                <span className="text-3xl">🌐</span>
              </div>
              <h4 className="font-bold text-xl text-gray-800">Web</h4>
              <p className="text-gray-600 mt-2">Access from any browser</p>
            </div>
            <div className="text-center">
              <div className="w-16 h-16 bg-purple-100 rounded-2xl flex items-center justify-center mx-auto mb-4">
                <span className="text-3xl">🍎</span>
              </div>
              <h4 className="font-bold text-xl text-gray-800">iOS</h4>
              <p className="text-gray-600 mt-2">Native iPhone app</p>
            </div>
            <div className="text-center">
              <div className="w-16 h-16 bg-purple-100 rounded-2xl flex items-center justify-center mx-auto mb-4">
                <span className="text-3xl">🤖</span>
              </div>
              <h4 className="font-bold text-xl text-gray-800">Android</h4>
              <p className="text-gray-600 mt-2">Native Android app</p>
            </div>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="bg-gray-900 text-white py-8 px-4 text-center">
        <p>&copy; 2026 Pointify. All rights reserved.</p>
      </footer>
    </main>
  )
}
