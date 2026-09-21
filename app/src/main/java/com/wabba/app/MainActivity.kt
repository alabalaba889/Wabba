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
import androidx.compose.material3.OutlinedButton
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
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.unit.dp
import com.wabba.app.ai.AIProviderFactory
import com.wabba.app.ai.AIRequest
import com.wabba.app.ai.ProviderConfig
import com.wabba.app.model.ChatMessage
import com.wabba.app.model.Project
import com.wabba.app.security.SecureProviderStore
import kotlinx.coroutines.launch
import java.util.UUID
import java.util.concurrent.atomic.AtomicLong

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent { WabbaApp() }
    }
}

@Composable
fun WabbaApp() {
    MaterialTheme {
        Surface(Modifier.fillMaxSize()) { WabbaRoot() }
    }
}

@Composable
private fun WabbaRoot() {
    var selectedTab by remember { mutableStateOf(0) }
    val projects = remember {
        mutableStateListOf(Project("demo", "Meu primeiro projeto", "Projeto de demonstração da Wabba."))
    }
    Scaffold(bottomBar = {
        NavigationBar {
            NavigationBarItem(selected = selectedTab == 0, onClick = { selectedTab = 0 }, icon = { Icon(Icons.Default.Folder, "Projetos") }, label = { Text("Projetos") })
            NavigationBarItem(selected = selectedTab == 1, onClick = { selectedTab = 1 }, icon = { Icon(Icons.Default.Memory, "IA") }, label = { Text("IA") })
            NavigationBarItem(selected = selectedTab == 2, onClick = { selectedTab = 2 }, icon = { Icon(Icons.Default.Settings, "Configurações") }, label = { Text("Configurações") })
        }
    }) { padding ->
        when (selectedTab) {
            0 -> ProjectsScreen(
                projects = projects,
                onCreateProject = { name ->
                    val clean = name.trim()
                    if (clean.isNotEmpty()) projects.add(Project(UUID.randomUUID().toString(), clean, "Projeto criado na Wabba."))
                },
                modifier = Modifier.padding(padding)
            )
            1 -> AIScreen(Modifier.padding(padding))
            else -> SettingsScreen(Modifier.padding(padding))
        }
    }
}

@Composable
private fun ProjectsScreen(
    projects: List<Project>,
    onCreateProject: (String) -> Unit,
    modifier: Modifier = Modifier
) {
    var name by remember { mutableStateOf("") }
    Column(modifier.fillMaxSize().padding(20.dp)) {
        Text("Wabba Luks", style = MaterialTheme.typography.headlineMedium)
        Spacer(Modifier.height(6.dp))
        Text("Seus projetos", style = MaterialTheme.typography.titleLarge)
        Spacer(Modifier.height(16.dp))
        Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            OutlinedTextField(
                value = name,
                onValueChange = { name = it },
                modifier = Modifier.weight(1f).testTag("projectNameInput"),
                singleLine = true,
                label = { Text("Nome do projeto") }
            )
            Button(
                onClick = { onCreateProject(name); name = "" },
                enabled = name.trim().isNotEmpty(),
                modifier = Modifier.testTag("createProjectButton")
            ) { Text("Criar projeto") }
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
    val context = LocalContext.current.applicationContext
    val messages = remember {
        mutableStateListOf(
            ChatMessage(1L, ChatMessage.Role.ASSISTANT, "Olá! Descreva o aplicativo que você quer construir.")
        )
    }
    val chatListState = rememberLazyListState()
    var prompt by remember { mutableStateOf("") }
    var busy by remember { mutableStateOf(false) }
    val scope = rememberCoroutineScope()
    val nextId = remember { AtomicLong(1L) }

    Column(modifier.fillMaxSize().padding(20.dp)) {
        Text("Wabba IA", style = MaterialTheme.typography.headlineMedium)
        Spacer(Modifier.height(12.dp))
        LazyColumn(
            Modifier.weight(1f).testTag("chatList"),
            state = chatListState,
            verticalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            items(messages, key = { it.id }) { message ->
                Text(
                    if (message.role == ChatMessage.Role.USER) "Você: ${message.text}"
                    else "Wabba: ${message.text}",
                    style = MaterialTheme.typography.bodyLarge
                )
            }
        }
        OutlinedTextField(
            value = prompt,
            onValueChange = { prompt = it },
            modifier = Modifier.fillMaxWidth().testTag("aiPromptInput"),
            enabled = !busy,
            label = { Text("Descreva sua ideia") }
        )
        Spacer(Modifier.height(8.dp))
        Button(
            onClick = {
                val clean = prompt.trim()
                if (clean.isEmpty() || busy) return@Button
                messages.add(ChatMessage(nextId.incrementAndGet(), ChatMessage.Role.USER, clean))
                prompt = ""
                busy = true
                scope.launch {
                    try {
                        val provider = AIProviderFactory.create(context)
                        val response = provider.generate(AIRequest(clean, model = SecureProviderStore(context).load()?.model))
                        messages.add(ChatMessage(nextId.incrementAndGet(), ChatMessage.Role.ASSISTANT, response.text))
                    } catch (error: Exception) {
                        messages.add(
                            ChatMessage(
                                nextId.incrementAndGet(),
                                ChatMessage.Role.ASSISTANT,
                                "Não foi possível processar: ${error.message ?: "erro desconhecido"}"
                            )
                        )
                    } finally {
                        busy = false
                    }
                    chatListState.animateScrollToItem(messages.lastIndex)
                }
            },
            enabled = prompt.trim().isNotEmpty() && !busy,
            modifier = Modifier.testTag("sendAiButton")
        ) {
            Text(if (busy) "Processando..." else "Enviar")
        }
    }
}

@Composable
private fun SettingsScreen(modifier: Modifier = Modifier) {
    val context = LocalContext.current.applicationContext
    val store = remember { SecureProviderStore(context) }
    val existing = remember { store.load() }
    var providerId by remember { mutableStateOf(existing?.providerId ?: "openai-compatible") }
    var baseUrl by remember { mutableStateOf(existing?.baseUrl ?: "https://api.openai.com/v1") }
    var model by remember { mutableStateOf(existing?.model ?: "") }
    var apiKey by remember { mutableStateOf("") }
    var saved by remember { mutableStateOf(existing != null) }

    Column(modifier.fillMaxSize().padding(20.dp)) {
        Text("Configurações", style = MaterialTheme.typography.headlineMedium)
        Spacer(Modifier.height(12.dp))
        Text("Provedores de IA", style = MaterialTheme.typography.titleLarge)
        Spacer(Modifier.height(6.dp))
        Text("A chave é armazenada usando o Android Keystore. Ela não é exibida novamente, não é escrita em logs e não entra no código-fonte.")
        Spacer(Modifier.height(12.dp))
        OutlinedTextField(
            value = providerId,
            onValueChange = { providerId = it },
            modifier = Modifier.fillMaxWidth().testTag("providerIdInput"),
            singleLine = true,
            label = { Text("ID do provedor") }
        )
        Spacer(Modifier.height(8.dp))
        OutlinedTextField(
            value = baseUrl,
            onValueChange = { baseUrl = it },
            modifier = Modifier.fillMaxWidth().testTag("providerBaseUrlInput"),
            singleLine = true,
            label = { Text("Base URL") }
        )
        Spacer(Modifier.height(8.dp))
        OutlinedTextField(
            value = model,
            onValueChange = { model = it },
            modifier = Modifier.fillMaxWidth().testTag("providerModelInput"),
            singleLine = true,
            label = { Text("Modelo") }
        )
        Spacer(Modifier.height(8.dp))
        OutlinedTextField(
            value = apiKey,
            onValueChange = { apiKey = it },
            modifier = Modifier.fillMaxWidth().testTag("providerApiKeyInput"),
            singleLine = true,
            label = { Text(if (saved) "Nova chave (deixe vazio para manter)" else "API Key") }
        )
        Spacer(Modifier.height(10.dp))
        Button(
            onClick = {
                if (apiKey.isNotBlank()) {
                    store.save(ProviderConfig(providerId.trim(), baseUrl.trim(), model.trim(), apiKey))
                    apiKey = ""
                    saved = true
                }
            },
            enabled = providerId.isNotBlank() && baseUrl.isNotBlank() && model.isNotBlank() && apiKey.isNotBlank(),
            modifier = Modifier.testTag("saveProviderButton")
        ) { Text("Salvar provedor") }
        Spacer(Modifier.height(8.dp))
        OutlinedButton(
            onClick = { store.clear(); apiKey = ""; saved = false },
            modifier = Modifier.testTag("clearProviderButton")
        ) { Text("Remover provedor e chave") }
        Spacer(Modifier.height(10.dp))
        Text(if (saved) "Provedor externo configurado." else "Provedor local: Mock")
    }
}
