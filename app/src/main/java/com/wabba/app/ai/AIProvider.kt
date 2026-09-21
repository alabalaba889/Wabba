package com.wabba.app.ai

data class AIMessage(val role: String, val content: String)

data class AIRequest(
    val prompt: String,
    val model: String? = null,
    val temperature: Double = 0.2,
    val history: List<AIMessage> = emptyList()
)

data class AIResponse(
    val text: String,
    val provider: String,
    val model: String?,
    val latencyMs: Long
)

interface AIProvider {
    val id: String
    suspend fun generate(request: AIRequest): AIResponse
}
