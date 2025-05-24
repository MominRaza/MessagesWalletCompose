package com.mominraza.messages_wallet.ui.screens

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.MoreVert
import androidx.compose.material3.Card
import androidx.compose.material3.DropdownMenu
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun HomeScreen(modifier: Modifier = Modifier) {
    var menuExpanded by remember { mutableStateOf(false) }

    Scaffold(
        modifier = modifier.fillMaxSize(),
        topBar = {
            TopAppBar(
                title = { Text("Messages Wallet") },
                actions = {
                    IconButton(onClick = { menuExpanded = true }) {
                        Icon(imageVector = Icons.Default.MoreVert, "More options")
                    }
                    DropdownMenu(
                        expanded = menuExpanded,
                        onDismissRequest = { menuExpanded = false }
                    ) {
                        DropdownMenuItem(
                            text = { Text("Settings") },
                            onClick = { menuExpanded = false }
                        )
                        DropdownMenuItem(
                            text = { Text("Star Github Repo") },
                            onClick = { menuExpanded = false }
                        )
                        DropdownMenuItem(
                            text = { Text("Feedback") },
                            onClick = { menuExpanded = false }
                        )
                    }
                }
            )
        }
    ) { innerPadding ->
        Column(modifier = Modifier
            .padding(innerPadding)
            .fillMaxSize()) {
            Card {
                Column {
                    Text("Bank of Baroda 7544")
                    Text("Final Balance: ₹6,670")
                    Text("Transactions")
                    Row {
                        Text("May 23, 2025 at 10:51 AM")
                        Text("₹6,000")
                    }
                    Row {
                        Text("May 23, 2025 at 10:51 AM")
                        Text("₹310")
                    }
                    Row {
                        Text("May 23, 2025 at 10:51 AM")
                        Text("- ₹140")
                    }
                }
            }
            Card {
                Column {
                    Text("Bank of Baroda 7544")
                    Text("Final Balance: ₹6,670")
                    Text("Transactions")
                    Row {
                        Text("May 23, 2025 at 10:51 AM")
                        Text("₹6,000")
                    }
                    Row {
                        Text("May 23, 2025 at 10:51 AM")
                        Text("₹310")
                    }
                    Row {
                        Text("May 23, 2025 at 10:51 AM")
                        Text("- ₹140")
                    }
                }
            }
            Card {
                Column {
                    Text("Bank of Baroda 7544")
                    Text("Final Balance: ₹6,670")
                    Text("Transactions")
                    Row {
                        Text("May 23, 2025 at 10:51 AM")
                        Text("₹6,000")
                    }
                    Row {
                        Text("May 23, 2025 at 10:51 AM")
                        Text("₹310")
                    }
                    Row {
                        Text("May 23, 2025 at 10:51 AM")
                        Text("- ₹140")
                    }
                }
            }
            Card {
                Column {
                    Text("Bank of Baroda 7544")
                    Text("Final Balance: ₹6,670")
                    Text("Transactions")
                    Row {
                        Text("May 23, 2025 at 10:51 AM")
                        Text("₹6,000")
                    }
                    Row {
                        Text("May 23, 2025 at 10:51 AM")
                        Text("₹310")
                    }
                    Row {
                        Text("May 23, 2025 at 10:51 AM")
                        Text("- ₹140")
                    }
                }
            }
        }
    }
}

@Preview
@Composable
fun HomeScreenPreview() {
    HomeScreen()
}