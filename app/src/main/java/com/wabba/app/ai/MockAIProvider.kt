package com.wabba.app.ai

class MockAIProvider : AIProvider {
    override val id = "mock"

    override suspend fun generate(request: AIRequest): AIResponse {
        val started = System.currentTimeMillis()
        val clean = request.prompt.trim()
        val lower = clean.lowercase()

        val response = when {
            clean.isEmpty() -> "Descreva o que você quer construir."

            isGreeting(lower) -> {
                "Oi! 👋 Eu sou a Wabba. Posso conversar com você e também transformar uma ideia em um projeto de verdade. " +
                    "Por exemplo: "crie um app de tarefas com login e notificações"."
            }

            isHelpRequest(lower) -> {
                "Posso trabalhar em etapas: entender a ideia, definir requisitos, montar a arquitetura, criar tarefas, implementar, testar, corrigir erros e preparar o build."
            }

            isProjectRequest(lower) -> buildProjectPlan(clean)

            else -> {
                "Entendi: "$clean". " +
                    "Isso parece uma conversa/solicitação geral, não necessariamente uma ordem para criar um projeto. " +
                    "Se você quiser construir algo, diga "crie um aplicativo..." e eu transformo a ideia em requisitos, arquitetura, tarefas e testes."
            }
        }

        return AIResponse(
            text = response,
            provider = id,
            model = request.model,
            latencyMs = System.currentTimeMillis() - started
        )
    }

    private fun isGreeting(text: String): Boolean {
        val greetings = listOf(
            "oi", "olá", "ola", "hello", "hi", "bom dia", "boa tarde", "boa noite"
        )
        return greetings.any { greeting ->
            text == greeting || text.startsWith("$greeting ") || text.startsWith("$greeting!")
        }
    }

    private fun isHelpRequest(text: String): Boolean =
        text.contains("ajuda") ||
            text.contains("o que você faz") ||
            text.contains("o que voce faz") ||
            text.contains("como funciona")

    private fun isProjectRequest(text: String): Boolean =
        listOf(
            "crie", "criar", "construa", "construir", "desenvolva", "desenvolver",
            "faça um app", "faca um app", "faça um aplicativo", "faca um aplicativo",
            "quero um aplicativo", "quero um app", "aplicativo com", "app com"
        ).any { text.contains(it) }

    private fun buildProjectPlan(idea: String): String = """
        Entendi a ideia: "$idea"

        Wabba Manager
        1. Análise: identificar objetivo, usuários e requisitos.
        2. Arquitetura: definir telas, dados, integrações e componentes.
        3. Tarefas: quebrar o desenvolvimento em tarefas executáveis.
        4. Desenvolvimento: implementar cada tarefa em ordem.
        5. Testes: criar e executar testes unitários e de interface.
        6. Debug: corrigir falhas encontradas e repetir os testes.
        7. Build: gerar o APK e registrar o resultado.

        Estado atual: PLANEJAMENTO
        Próxima ação: transformar essa ideia em requisitos e tarefas concretas.
    """.trimIndent()
}
