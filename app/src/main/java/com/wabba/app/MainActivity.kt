package com.wabba.app

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Folder
import androidx.compose.material.icons.filled.Memory
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material3.Button
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateListOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.unit.dp
import com.wabba.app.ai.AIProviderRegistry
import com.wabba.app.ai.AIRequest
import com.wabba.app.model.ChatMessage
import com.wabba.app.model.Project
import kotlinx.coroutines.launch
import java.util.UUID

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent { WabbaApp() }
    }
}

@Composable
fun WabbaApp() {
    MaterialTheme {
        Surface(modifier = Modifier.fillMaxSize()) {
            WabbaRoot()
        }
    }
}

@Composable
private fun WabbaRoot() {
    var selectedTab by remember { mutableStateOf(0) }
    val projects = remember { mutableStateListOf(Project("demo", "Meu primeiro projeto", "Projeto de demonstração da Wabba.")) }
    Scaffold(bottomBar = {
        NavigationBar {
            NavigationBarItem(selected = selectedTab == 0, onClick = { selectedTab = 0 }, icon = { Icon(Icons.Default.Folder, "Projetos") }, label = { Text("Projetos") })
            NavigationBarItem(selected = selectedTab == 1, onClick = { selectedTab = 1 }, icon = { Icon(Icons.Default.Memory, "IA") }, label = { Text("IA") })
            NavigationBarItem(selected = selectedTab == 2, onClick = { selectedTab = 2 }, icon = { Icon(Icons.Default.Settings, "Configurações") }, label = { Text("Configurações") })
        }
    }) { padding ->
        when (selectedTab) {
            0 -> ProjectsScreen(projects, { name -> val clean = name.trim(); if (clean.isNotEmpty()) projects.add(Project(UUID.randomUUID().toString(), clean, "Projeto criado na Wabba.")) }, Modifier.padding(padding))
            1 -> AIScreen(Modifier.padding(padding))
            else -> SettingsScreen(Modifier.padding(padding))
        }
    }
}

@Composable
private fun ProjectsScreen(projects: List<Project>, onCreateProject: (String) -> Unit, modifier: Modifier = Modifier) {
    var name by remember { mutableStateOf("") }
    Column(modifier.fillMaxSize().padding(20.dp)) {
        Text("Wabba Luks", style = MaterialTheme.typography.headlineMedium)
        Spacer(Modifier.height(6.dp))
        Text("Seus projetos", style = MaterialTheme.typography.titleLarge)
        Spacer(Modifier.height(16.dp))
        Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            OutlinedTextField(value = name, onValueChange = { name = it }, modifier = Modifier.weight(1f).testTag("projectNameInput"), singleLine = true, label = { Text("Nome do projeto") })
            Button(onClick = { onCreateProject(name); name = "" }, enabled = name.trim().isNotEmpty(), modifier = Modifier.testTag("createProjectButton")) { Text("Criar projeto") }
        }
        Spacer(Modifier.height(20.dp))
        LazyColumn(verticalArrangement = Arrangement.spacedBy(10.dp)) {
            items(projects, key = { it.id }) { project ->
                Surface(Modifier.fillMaxWidth(), tonalElevation = 2.dp, shape = MaterialTheme.shapes.medium) {
                    Column(Modifier.padding(16.dp)) {
                        Text(project.name, style = MaterialTheme.typography.titleMedium)
                        Text(project.description)
                        Text("${project.status} • ${project.progress}%", style = MaterialTheme.typography.labelMedium)
                    }
                }
            }
        }
    }
}

@Composable
private fun AIScreen(modifier: Modifier = Modifier) {
    val provider = remember { AIProviderRegistry().get("mock") }
    val messages = remember { mutableStateListOf(ChatMessage(1L, ChatMessage.Role.ASSISTANT, "Olá! Descreva o aplicativo que você quer construir.")) }
    val chatListState = rememberLazyListState()
    var prompt by remember { mutableStateOf("") }
    var busy by remember { mutableStateOf(false) }
    val scope = rememberCoroutineScope()
    Column(modifier.fillMaxSize().padding(20.dp)) {
        Text("Wabba IA", style = MaterialTheme.typography.headlineMedium)
        Spacer(Modifier.height(12.dp))
        LazyColumn(Modifier.weight(1f).testTag("chatList"), state = chatListState, verticalArrangement = Arrangement.spacedBy(8.dp)) {
            items(messages, key = { it.id }) { message ->
                Text(if (message.role == ChatMessage.Role.USER) "Você: ${message.text}" else "Wabba: ${message.text}", style = MaterialTheme.typography.bodyLarge)
            }
        }
        OutlinedTextField(value = prompt, onValueChange = { prompt = it }, modifier = Modifier.fillMaxWidth().testTag("aiPromptInput"), enabled = !busy, label = { Text("Descreva sua ideia") })
        Spacer(Modifier.height(8.dp))
        Button(onClick = {
            val clean = prompt.trim()
            if (clean.isEmpty() || busy || provider == null) return@Button
            messages.add(ChatMessage(System.nanoTime(), ChatMessage.Role.USER, clean))
            prompt = ""
            scope.launch { chatListState.animateScrollToItem(messages.lastIndex) }
            busy = true
            scope.launch {
                try {
                    val response = provider.generate(AIRequest(clean))
                    messages.add(ChatMessage(System.nanoTime(), ChatMessage.Role.ASSISTANT, response.text))
                    chatListState.animateScrollToItem(messages.lastIndex)
                } catch (error: Exception) {
                    messages.add(ChatMessage(System.nanoTime(), ChatMessage.Role.ASSISTANT, "Não foi possível processar: ${error.message ?: "erro desconhecido"}"))
                } finally { busy = false }
            }
        }, enabled = prompt.trim().isNotEmpty() && !busy && provider != null, modifier = Modifier.testTag("sendAiButton")) {
            Text(if (busy) "Processando..." else "Enviar")
        }
    }
}

@Composable
private fun SettingsScreen(modifier: Modifier = Modifier) {
    Column(modifier.fillMaxSize().padding(20.dp)) {
        Text("Configurações", style = MaterialTheme.typography.headlineMedium)
        Spacer(Modifier.height(12.dp))
        Text("Provedores de IA", style = MaterialTheme.typography.titleLarge)
        Spacer(Modifier.height(6.dp))
        Text("A Wabba usa uma camada de provedores para permitir integração com diferentes modelos. Chaves reais nunca devem ser colocadas no código, frontend, README ou logs.")
        Spacer(Modifier.height(12.dp))
        Text("Provedor local: Mock")
    }
}