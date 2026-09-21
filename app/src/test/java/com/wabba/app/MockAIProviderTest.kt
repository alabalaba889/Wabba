package com.wabba.app

import com.wabba.app.ai.AIRequest
import com.wabba.app.ai.MockAIProvider
import kotlinx.coroutines.runBlocking
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class MockAIProviderTest {
    @Test fun generatesResponseForPrompt() = runBlocking {
        val result = MockAIProvider().generate(AIRequest("criar app de tarefas", model = "mock-v1"))
        assertTrue(result.text.contains("criar app de tarefas"))
        assertEquals("mock", result.provider)
        assertEquals("mock-v1", result.model)
        assertTrue(result.latencyMs >= 0)
    }

    @Test fun respondsNaturallyToGreeting() = runBlocking {
        val result = MockAIProvider().generate(AIRequest("oi"))
        assertTrue(result.text.startsWith("Oi!"))
        assertTrue(!result.text.contains("Wabba analisou sua ideia"))
    }

    @Test fun separatesConversationFromBuildIntent() = runBlocking {
        val result = MockAIProvider().generate(AIRequest("qual é a função da wabba?"))
        assertTrue(result.text.contains("não necessariamente uma ordem para criar um projeto"))
    }

    @Test fun handlesBlankPrompt() = runBlocking {
        val result = MockAIProvider().generate(AIRequest("   "))
        assertEquals("Descreva o que você quer construir.", result.text)
        assertTrue(result.latencyMs >= 0)
    }

    @Test fun trimsPromptBeforeGenerating() = runBlocking {
        val result = MockAIProvider().generate(AIRequest("  criar dashboard  "))
        assertTrue(result.text.contains("criar dashboard"))
        assertTrue(!result.text.contains("  criar dashboard  "))
    }

    @Test fun preservesTemperatureAndRequestContract() {
        val request = AIRequest("ideia", model = null, temperature = 0.7)
        assertEquals(0.7, request.temperature, 0.0)
        assertEquals("ideia", request.prompt)
    }
}
