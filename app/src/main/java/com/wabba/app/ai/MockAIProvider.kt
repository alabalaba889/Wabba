package com.wabba.app.ai

class MockAIProvider : AIProvider {
    override val id = "mock"
    override suspend fun generate(request: AIRequest): AIResponse {
        val started = System.currentTimeMillis()
        val clean = request.prompt.trim()
        val response = if (clean.isEmpty()) "Descreva o que você quer construir."
        else "Wabba analisou sua ideia: " + clean + "\n\nPróximo passo: transformar a ideia em plano, arquitetura, tarefas e testes."
        return AIResponse(response, id, request.model, System.currentTimeMillis() - started)
    }
}
