package com.pointify.app.data

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class Point(
    val id: String,
    val name: String,
    val description: String? = null,
    @SerialName("image_url") val imageUrl: String? = null,
    val lat: Double,
    val lon: Double,
    val type: String = "social",
    @SerialName("creator_id") val creatorId: String? = null,
    @SerialName("posts_count") val postsCount: Int = 0,
    @SerialName("events_count") val eventsCount: Int = 0,
    @SerialName("distance_km") val distanceKm: Double? = null,
    @SerialName("created_at") val createdAt: String? = null
)

@Serializable
data class Post(
    val id: String,
    @SerialName("point_id") val pointId: String,
    @SerialName("creator_id") val creatorId: String? = null,
    val header: String? = null,
    val body: String? = null,
    @SerialName("image_url") val imageUrl: String? = null,
    @SerialName("created_at") val createdAt: String? = null
)

@Serializable
data class Event(
    val id: String,
    @SerialName("point_id") val pointId: String,
    @SerialName("creator_id") val creatorId: String? = null,
    val title: String,
    val info: String? = null,
    @SerialName("image_url") val imageUrl: String? = null,
    @SerialName("start_date") val startDate: String,
    @SerialName("end_date") val endDate: String,
    @SerialName("created_at") val createdAt: String? = null
)

@Serializable
data class Profile(
    val id: String,
    val name: String? = null,
    val nickname: String? = null,
    val phone: String? = null,
    @SerialName("avatar_url") val avatarUrl: String? = null
)
