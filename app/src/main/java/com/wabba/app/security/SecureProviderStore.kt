package com.wabba.app.security

import android.content.Context
import android.util.Base64
import com.wabba.app.ai.ProviderConfig
import java.nio.charset.StandardCharsets
import java.security.KeyStore
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.spec.GCMParameterSpec
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties

class SecureProviderStore(context: Context) {
    private val preferences = context.applicationContext.getSharedPreferences("wabba_secure_provider", Context.MODE_PRIVATE)

    fun load(): ProviderConfig? {
        val providerId = preferences.getString(KEY_PROVIDER, null) ?: return null
        val baseUrl = preferences.getString(KEY_BASE_URL, null) ?: return null
        val model = preferences.getString(KEY_MODEL, null) ?: return null
        val encrypted = preferences.getString(KEY_API_KEY, null) ?: return null
        val apiKey = decrypt(encrypted) ?: return null
        return ProviderConfig(providerId, baseUrl, model, apiKey).takeIf { it.isUsable() }
    }

    fun save(config: ProviderConfig) {
        require(config.isUsable()) { "Configuração de provedor incompleta." }
        preferences.edit()
            .putString(KEY_PROVIDER, config.providerId)
            .putString(KEY_BASE_URL, config.baseUrl.trimEnd('/'))
            .putString(KEY_MODEL, config.model)
            .putString(KEY_API_KEY, encrypt(config.apiKey))
            .apply()
    }

    fun clear() {
        preferences.edit().clear().apply()
    }

    private fun secretKey(): SecretKey {
        val keyStore = KeyStore.getInstance(ANDROID_KEYSTORE).apply { load(null) }
        val existing = keyStore.getKey(KEY_ALIAS, null)
        if (existing is SecretKey) return existing
        val generator = KeyGenerator.getInstance(KeyProperties.KEY_ALGORITHM_AES, ANDROID_KEYSTORE)
        generator.init(
            KeyGenParameterSpec.Builder(
                KEY_ALIAS,
                KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT
            )
                .setBlockModes(KeyProperties.BLOCK_MODE_GCM)
                .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE)
                .build()
        )
        return generator.generateKey()
    }

    private fun encrypt(value: String): String {
        val cipher = Cipher.getInstance(TRANSFORMATION)
        cipher.init(Cipher.ENCRYPT_MODE, secretKey())
        val encrypted = cipher.doFinal(value.toByteArray(StandardCharsets.UTF_8))
        return Base64.encodeToString(cipher.iv + encrypted, Base64.NO_WRAP)
    }

    private fun decrypt(value: String): String? = runCatching {
        val packed = Base64.decode(value, Base64.NO_WRAP)
        require(packed.size > IV_LENGTH)
        val iv = packed.copyOfRange(0, IV_LENGTH)
        val ciphertext = packed.copyOfRange(IV_LENGTH, packed.size)
        val cipher = Cipher.getInstance(TRANSFORMATION)
        cipher.init(Cipher.DECRYPT_MODE, secretKey(), GCMParameterSpec(TAG_BITS, iv))
        String(cipher.doFinal(ciphertext), StandardCharsets.UTF_8)
    }.getOrNull()

    private companion object {
        const val ANDROID_KEYSTORE = "AndroidKeyStore"
        const val KEY_ALIAS = "wabba_api_key"
        const val TRANSFORMATION = "AES/GCM/NoPadding"
        const val IV_LENGTH = 12
        const val TAG_BITS = 128
        const val KEY_PROVIDER = "provider"
        const val KEY_BASE_URL = "base_url"
        const val KEY_MODEL = "model"
        const val KEY_API_KEY = "api_key"
    }
}
