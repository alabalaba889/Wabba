package com.wabba.app

import com.wabba.app.ai.ProviderConfig
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class ProviderConfigTest {
    @Test fun usableConfigIsAccepted() {
        assertTrue(ProviderConfig("openai-compatible", "https://api.example.com/v1", "model-1", "secret").isUsable())
    }

    @Test fun incompleteConfigIsRejected() {
        assertFalse(ProviderConfig("provider", "url", "model", "").isUsable())
        assertFalse(ProviderConfig("", "url", "model", "key").isUsable())
        assertFalse(ProviderConfig("provider", "", "model", "key").isUsable())
        assertFalse(ProviderConfig("provider", "url", "", "key").isUsable())
    }
}
