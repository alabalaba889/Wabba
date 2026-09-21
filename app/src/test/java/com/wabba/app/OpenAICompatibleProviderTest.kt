package com.wabba.app

import com.wabba.app.ai.AIRequest
import com.wabba.app.ai.OpenAICompatibleProvider
import kotlinx.coroutines.runBlocking
import org.junit.Assert.assertEquals
import org.junit.Test

class OpenAICompatibleProviderTest {
    @Test(expected = IllegalArgumentException::class)
    fun blankKeyFailsBeforeNetworkCall() = runBlocking {
        OpenAICompatibleProvider("", "https://api.example.com/v1").generate(AIRequest("hello", model = "test"))
    }

    @Test(expected = IllegalArgumentException::class)
    fun blankPromptFailsBeforeNetworkCall() = runBlocking {
        OpenAICompatibleProvider("secret", "https://api.example.com/v1").generate(AIRequest("   ", model = "test"))
    }

    @Test fun providerUsesStableId() {
        assertEquals("my-provider", OpenAICompatibleProvider("secret", "https://api.example.com/v1", "my-provider").id)
    }
}
