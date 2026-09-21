package com.wabba.app.ai

import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import org.json.JSONArray
import org.json.JSONObject
import java.net.HttpURLConnection
import java.net.URL

class OpenAICompatibleProvider(
    private val apiKey: String,
    private val baseUrl: String,
    override val id: String = "openai-compatible"
) : AIProvider {

    override suspend fun generate(request: AIRequest): AIResponse = withContext(Dispatchers.IO) {
        require(apiKey.isNotBlank()) { "A chave da API não foi configurada." }
        require(request.prompt.isNotBlank()) { "O prompt não pode estar vazio." }

        val started = System.currentTimeMillis()
        val endpoint = baseUrl.trimEnd('/') + "/chat/completions"
        val connection = (URL(endpoint).openConnection() as HttpURLConnection).apply {
            requestMethod = "POST"
            connectTimeout = 15_000
            readTimeout = 60_000
            doOutput = true
            setRequestProperty("Authorization", "Bearer $apiKey")
            setRequestProperty("Content-Type", "application/json")
            setRequestProperty("Accept", "application/json")
        }

        try {
            val messages = JSONArray()
                .put(
                    JSONObject()
                        .put("role", "system")
                        .put(
                            "content",
                            "Você é a Wabba Manager, uma IA de engenharia de software. " +
                                "Converse naturalmente. Só trate uma mensagem como pedido de desenvolvimento quando houver intenção clara de criar, alterar, testar ou corrigir um projeto. " +
                                "Quando houver intenção de desenvolvimento, organize o trabalho em análise, requisitos, arquitetura, tarefas, implementação, testes, correções e build. " +
                                "Não diga que executou código, testes ou builds se isso não aconteceu."
                        )
                )

            request.history.takeLast(20).forEach { message ->
                if (message.role == "user" || message.role == "assistant") {
                    messages.put(
                        JSONObject()
                            .put("role", message.role)
                            .put("content", message.content)
                    )
                }
            }

            messages.put(
                JSONObject()
                    .put("role", "user")
                    .put("content", request.prompt.trim())
            )

            val body = JSONObject()
                .put("model", request.model ?: "")
                .put("temperature", request.temperature)
                .put("messages", messages)
                .toString()

            connection.outputStream.use { it.write(body.toByteArray(Charsets.UTF_8)) }
            val status = connection.responseCode
            val stream = if (status in 200..299) connection.inputStream else connection.errorStream
            val responseBody = stream?.bufferedReader()?.use { it.readText() }.orEmpty()

            if (status !in 200..299) {
                throw IllegalStateException("Provedor retornou HTTP $status.")
            }

            val text = JSONObject(responseBody)
                .getJSONArray("choices")
                .getJSONObject(0)
                .getJSONObject("message")
                .getString("content")

            AIResponse(
                text = text,
                provider = id,
                model = request.model,
                latencyMs = System.currentTimeMillis() - started
            )
        } finally {
            connection.disconnect()
        }
    }
}
