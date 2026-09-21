package com.wabba.app
import com.wabba.app.ai.AIProviderRegistry
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Test
class AIProviderRegistryTest {
    @Test fun registryContainsMockProvider() {
        val registry = AIProviderRegistry()
        assertNotNull(registry.get("mock"))
        assertEquals(listOf("mock"), registry.ids())
    }
}
