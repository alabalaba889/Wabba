package com.wabba.app.ai

data class AIRequest(val prompt: String, val model: String? = null, val temperature: Double = 0.2)
data class AIResponse(val text: String, val provider: String, val model: String?, val latencyMs: Long)

interface AIProvider {
    val id: String
    suspend fun generate(request: AIRequest): AIResponse
}
