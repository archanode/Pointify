package com.pointify.app.data

import org.json.JSONArray

class PointifyRepository {

    suspend fun getNearbyPoints(lat: Double, lon: Double, radiusKm: Double = 50.0): List<Point> {
        val response = SupabaseClient.rpc(
            "get_nearby_points",
            mapOf("user_lat" to lat, "user_lon" to lon, "radius_km" to radiusKm)
        )

        return parsePoints(response)
    }

    private fun parsePoints(json: String): List<Point> {
        val points = mutableListOf<Point>()
        try {
            val array = JSONArray(json)
            for (i in 0 until array.length()) {
                val obj = array.getJSONObject(i)
                points.add(Point(
                    id = obj.getString("id"),
                    name = obj.getString("name"),
                    description = obj.optString("description", null),
                    imageUrl = obj.optString("image_url", null),
                    lat = obj.getDouble("lat"),
                    lon = obj.getDouble("lon"),
                    type = obj.optString("type", "social"),
                    creatorId = obj.optString("creator_id", null),
                    postsCount = obj.optInt("posts_count", 0),
                    eventsCount = obj.optInt("events_count", 0),
                    distanceKm = if (obj.has("distance_km")) obj.getDouble("distance_km") else null,
                    createdAt = obj.optString("created_at", null)
                ))
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
        return points
    }
}
