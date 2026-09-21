package com.wabba.app.model
data class ChatMessage(val id: Long, val role: Role, val text: String) {
    enum class Role { USER, ASSISTANT }
}
