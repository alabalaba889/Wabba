package com.wabba.app.ai

data class ProviderConfig(
    val providerId: String,
    val baseUrl: String,
    val model: String,
    val apiKey: String
) {
    fun isUsable(): Boolean =
        providerId.isNotBlank() && baseUrl.isNotBlank() && model.isNotBlank() && apiKey.isNotBlank()
}
