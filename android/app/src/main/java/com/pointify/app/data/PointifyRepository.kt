package com.pointify.app.data

import io.github.jan.supabase.auth.auth
import io.github.jan.supabase.auth.providers.builtin.Email
import io.github.jan.supabase.postgrest.postgrest
import io.github.jan.supabase.postgrest.rpc

class PointifyRepository {
    private val client = SupabaseClient.client

    val currentUserId: String?
        get() = client.auth.currentUserOrNull()?.id

    // Auth
    suspend fun signUp(email: String, password: String, name: String) {
        client.auth.signUpWith(Email) {
            this.email = email
            this.password = password
        }
    }

    suspend fun signIn(email: String, password: String) {
        client.auth.signInWith(Email) {
            this.email = email
            this.password = password
        }
    }

    suspend fun signOut() {
        client.auth.signOut()
    }

    // Points
    suspend fun getNearbyPoints(lat: Double, lon: Double, radiusKm: Double = 50.0): List<Point> {
        return client.postgrest.rpc(
            "get_nearby_points",
            mapOf("user_lat" to lat, "user_lon" to lon, "radius_km" to radiusKm)
        ).decodeList()
    }

    suspend fun createPoint(name: String, description: String?, lat: Double, lon: Double, type: String): Point {
        return client.postgrest.from("points").insert(
            mapOf(
                "name" to name,
                "description" to description,
                "lat" to lat,
                "lon" to lon,
                "type" to type,
                "creator_id" to currentUserId
            )
        ) { select() }.decodeSingle()
    }

    suspend fun deletePoint(id: String) {
        client.postgrest.from("points").delete { filter { eq("id", id) } }
    }

    // Posts
    suspend fun getPostsForPoint(pointId: String): List<Post> {
        return client.postgrest.from("posts").select {
            filter { eq("point_id", pointId) }
        }.decodeList()
    }

    suspend fun createPost(pointId: String, header: String?, body: String?): Post {
        return client.postgrest.from("posts").insert(
            mapOf(
                "point_id" to pointId,
                "creator_id" to currentUserId,
                "header" to header,
                "body" to body
            )
        ) { select() }.decodeSingle()
    }

    // Events
    suspend fun getEventsForPoint(pointId: String): List<Event> {
        return client.postgrest.from("events").select {
            filter { eq("point_id", pointId) }
        }.decodeList()
    }
}
