package com.mominraza.messages_wallet

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.navigation3.runtime.entry
import androidx.navigation3.runtime.entryProvider
import androidx.navigation3.runtime.rememberNavBackStack
import androidx.navigation3.ui.NavDisplay
import com.mominraza.messages_wallet.ui.screens.Bank
import com.mominraza.messages_wallet.ui.screens.BankScreen
import com.mominraza.messages_wallet.ui.screens.Home
import com.mominraza.messages_wallet.ui.screens.HomeScreen
import com.mominraza.messages_wallet.ui.screens.Landing
import com.mominraza.messages_wallet.ui.screens.LandingScreen
import com.mominraza.messages_wallet.ui.screens.Permission
import com.mominraza.messages_wallet.ui.screens.PermissionScreen
import com.mominraza.messages_wallet.ui.screens.Settings
import com.mominraza.messages_wallet.ui.screens.SettingsScreen
import com.mominraza.messages_wallet.ui.theme.MessagesWalletTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            val backStack = rememberNavBackStack(Landing)

            MessagesWalletTheme {
                NavDisplay(
                    backStack = backStack,
                    entryProvider =
                        entryProvider {
                            entry<Landing> {
                                LandingScreen(backStack)
                            }
                            entry<Permission> {
                                PermissionScreen(backStack)
                            }
                            entry<Home> {
                                HomeScreen(backStack)
                            }
                            entry<Bank> {
                                BankScreen(backStack)
                            }
                            entry<Settings> {
                                SettingsScreen(backStack)
                            }
                        }
                )
            }
        }
    }
}
