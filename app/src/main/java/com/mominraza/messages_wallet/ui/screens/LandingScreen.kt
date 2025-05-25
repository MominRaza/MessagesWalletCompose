package com.mominraza.messages_wallet.ui.screens

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Button
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.navigation3.runtime.NavBackStack
import androidx.navigation3.runtime.NavKey
import kotlinx.serialization.Serializable

@Serializable
data object Landing : NavKey

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun LandingScreen(backStack: NavBackStack) {
    Scaffold(
        topBar = {
            TopAppBar(title = { Text("Landing Screen") })
        }
    ) { innerPadding ->
        Column {
            Text("Landing Screen", modifier = Modifier.padding(innerPadding))
            Button(onClick = { backStack.add(Permission) }) { Text("Go to Permission") }
        }
    }
}