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
data object Permission : NavKey

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun PermissionScreen(navBackStack: NavBackStack) {
    Scaffold(
        topBar = {
            TopAppBar(title = { Text("Permission Screen") })
        }
    ) { innerPadding ->
        Column {
            Text("Permission Screen", modifier = Modifier.padding(innerPadding))
            Button(onClick = { navBackStack.add(Home) }) { Text("Go to Home") }
        }
    }
}