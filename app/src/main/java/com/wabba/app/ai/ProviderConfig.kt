package com.wabba.app.ai

data class ProviderConfig(
    val providerId: String,
    val baseUrl: String,
    val model: String,
    val apiKey: String
) {
    fun isUsable(): Boolean =
        providerId.isNotBlank() &&
            baseUrl.startsWith("https://", ignoreCase = true) &&
            model.isNotBlank() &&
            apiKey.isNotBlank()
}
