package com.wabba.app
import com.wabba.app.ai.AIRequest
import com.wabba.app.ai.MockAIProvider
import kotlinx.coroutines.runBlocking
import org.junit.Assert.assertTrue
import org.junit.Test
class MockAIProviderTest {
    @Test fun generatesResponseForPrompt() = runBlocking {
        val result = MockAIProvider().generate(AIRequest("criar app de tarefas"))
        assertTrue(result.text.contains("criar app de tarefas"))
        assertTrue(result.provider == "mock")
    }
    @Test fun handlesBlankPrompt() = runBlocking {
        val result = MockAIProvider().generate(AIRequest("   "))
        assertTrue(result.text.isNotBlank())
    }
}
