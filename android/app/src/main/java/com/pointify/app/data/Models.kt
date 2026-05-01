package com.pointify.app.data

data class Point(
    val id: String,
    val name: String,
    val description: String? = null,
    val imageUrl: String? = null,
    val lat: Double,
    val lon: Double,
    val type: String = "social",
    val creatorId: String? = null,
    val postsCount: Int = 0,
    val eventsCount: Int = 0,
    val distanceKm: Double? = null,
    val createdAt: String? = null
)
