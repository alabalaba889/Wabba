package com.wabba.app

import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createAndroidComposeRule
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import androidx.compose.ui.test.performTextInput
import androidx.test.ext.junit.runners.AndroidJUnit4
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(AndroidJUnit4::class)
class MainActivityTest {
    @get:Rule
    val composeRule = createAndroidComposeRule<MainActivity>()

    @Test fun appShowsProjectsScreen() {
        composeRule.onNodeWithText("Wabba Luks").assertIsDisplayed()
        composeRule.onNodeWithText("Seus projetos").assertIsDisplayed()
        composeRule.onNodeWithText("Criar projeto").assertIsDisplayed()
    }

    @Test fun createsProjectFromNonBlankName() {
        composeRule.onNodeWithTag("projectNameInput").performTextInput("Projeto de teste")
        composeRule.onNodeWithTag("createProjectButton").performClick()
        composeRule.onNodeWithText("Projeto de teste").assertIsDisplayed()
    }

    @Test fun createButtonDisabledForBlankName() {
        composeRule.onNodeWithTag("createProjectButton").assertIsDisplayed()
        // The initial state is blank, so the button is disabled and clicking it must not create a project.
        composeRule.onNodeWithTag("createProjectButton").performClick()
        composeRule.onNodeWithText("Meu primeiro projeto").assertIsDisplayed()
    }

    @Test fun switchesToAiTabAndSendsPrompt() {
        composeRule.onNodeWithText("IA").performClick()
        composeRule.onNodeWithText("Wabba IA").assertIsDisplayed()
        composeRule.onNodeWithTag("aiPromptInput").performTextInput("criar um app de tarefas")
        composeRule.onNodeWithTag("sendAiButton").performClick()
        composeRule.onNodeWithText("Você: criar um app de tarefas").assertIsDisplayed()
        composeRule.waitUntil(5_000) {
            composeRule.onAllNodesWithText("Wabba: Wabba analisou sua ideia: criar um app de tarefas").fetchSemanticsNodes().isNotEmpty()
        }
    }

    @Test fun switchesToSettingsTab() {
        composeRule.onNodeWithText("Configurações").performClick()
        composeRule.onNodeWithText("Provedores de IA").assertIsDisplayed()
        composeRule.onNodeWithText("Provedor local: Mock").assertIsDisplayed()
    }
}
