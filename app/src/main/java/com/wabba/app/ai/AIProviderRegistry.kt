package com.wabba.app.ai

class AIProviderRegistry(providers: List<AIProvider> = listOf(MockAIProvider())) {
    private val byId = providers.associateBy { it.id }
    fun get(id: String): AIProvider? = byId[id]
    fun ids(): List<String> = byId.keys.toList()
}
