package com.wabba.app

import com.wabba.app.ai.AIRequest
import com.wabba.app.ai.OpenAICompatibleProvider
import kotlinx.coroutines.runBlocking
import org.junit.Assert.assertEquals
import org.junit.Assert.assertThrows
import org.junit.Test

class OpenAICompatibleProviderTest {
    @Test fun blankKeyFailsBeforeNetworkCall() = runBlocking {
        assertThrows(IllegalArgumentException::class.java) {
            runBlocking {
                OpenAICompatibleProvider("", "https://api.example.com/v1")
                    .generate(AIRequest("hello", model = "test"))
            }
        }
    }

    @Test fun blankPromptFailsBeforeNetworkCall() = runBlocking {
        assertThrows(IllegalArgumentException::class.java) {
            runBlocking {
                OpenAICompatibleProvider("secret", "https://api.example.com/v1")
                    .generate(AIRequest("   ", model = "test"))
            }
        }
    }

    @Test fun providerUsesStableId() {
        assertEquals(
            "my-provider",
            OpenAICompatibleProvider("secret", "https://api.example.com/v1", "my-provider").id
        )
    }
}
