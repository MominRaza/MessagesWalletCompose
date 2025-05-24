package com.mominraza.messages_wallet

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import com.mominraza.messages_wallet.ui.screens.HomeScreen
import com.mominraza.messages_wallet.ui.theme.MessagesWalletTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            MessagesWalletTheme {
                HomeScreen()
            }
        }
    }
}
