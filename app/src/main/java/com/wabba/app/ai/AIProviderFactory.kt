package com.wabba.app.ai

import android.content.Context
import com.wabba.app.security.SecureProviderStore

object AIProviderFactory {
    fun create(context: Context): AIProvider {
        val config = SecureProviderStore(context).load()
        return if (config?.isUsable() == true) {
            OpenAICompatibleProvider(
                apiKey = config.apiKey,
                baseUrl = config.baseUrl,
                id = config.providerId
            )
        } else {
            MockAIProvider()
        }
    }
}
