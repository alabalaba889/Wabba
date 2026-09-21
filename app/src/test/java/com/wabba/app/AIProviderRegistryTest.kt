package com.wabba.app

import com.wabba.app.ai.AIProvider
import com.wabba.app.ai.AIProviderRegistry
import com.wabba.app.ai.AIRequest
import com.wabba.app.ai.AIResponse
import kotlinx.coroutines.runBlocking
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Test

class AIProviderRegistryTest {
    private class FakeProvider(override val id: String) : AIProvider {
        override suspend fun generate(request: AIRequest) =
            AIResponse("ok", id, request.model, 0L)
    }

    @Test fun registryContainsMockProvider() {
        val registry = AIProviderRegistry()
        assertNotNull(registry.get("mock"))
        assertEquals(listOf("mock"), registry.ids())
    }

    @Test fun registryReturnsNullForUnknownProvider() {
        assertNull(AIProviderRegistry().get("does-not-exist"))
    }

    @Test fun registrySupportsCustomProviders() = runBlocking {
        val provider = FakeProvider("fake")
        val registry = AIProviderRegistry(listOf(provider))
        assertEquals(listOf("fake"), registry.ids())
        assertEquals("ok", registry.get("fake")!!.generate(AIRequest("hello")).text)
    }

    @Test fun duplicateProviderIdsUseLastProvider() {
        val first = FakeProvider("same")
        val second = FakeProvider("same")
        assertEquals(second, AIProviderRegistry(listOf(first, second)).get("same"))
    }
}
