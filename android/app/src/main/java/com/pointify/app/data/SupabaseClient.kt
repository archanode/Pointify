package com.pointify.app.data

import com.pointify.app.BuildConfig
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody
import org.json.JSONArray
import org.json.JSONObject
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

object SupabaseClient {
    private val client = OkHttpClient()
    private val JSON = "application/json".toMediaType()

    private val baseUrl = BuildConfig.SUPABASE_URL
    private val apiKey = BuildConfig.SUPABASE_KEY

    suspend fun rpc(functionName: String, params: Map<String, Any>): String = withContext(Dispatchers.IO) {
        val json = JSONObject(params).toString()
        val request = Request.Builder()
            .url("$baseUrl/rest/v1/rpc/$functionName")
            .addHeader("apikey", apiKey)
            .addHeader("Authorization", "Bearer $apiKey")
            .addHeader("Content-Type", "application/json")
            .post(json.toRequestBody(JSON))
            .build()

        client.newCall(request).execute().use { response ->
            response.body?.string() ?: "[]"
        }
    }

    suspend fun select(table: String, query: String = ""): String = withContext(Dispatchers.IO) {
        val url = if (query.isNotEmpty()) "$baseUrl/rest/v1/$table?$query" else "$baseUrl/rest/v1/$table"
        val request = Request.Builder()
            .url(url)
            .addHeader("apikey", apiKey)
            .addHeader("Authorization", "Bearer $apiKey")
            .get()
            .build()

        client.newCall(request).execute().use { response ->
            response.body?.string() ?: "[]"
        }
    }
}
