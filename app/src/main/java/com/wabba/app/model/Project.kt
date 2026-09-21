package com.wabba.app.model
data class Project(val id: String, val name: String, val description: String, val status: String = "Novo", val progress: Int = 0)
