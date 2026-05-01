package com.pointify.app.ui.theme

import androidx.compose.material3.*
import androidx.compose.runtime.Composable

private val LightColors = lightColorScheme(
    primary = androidx.compose.ui.graphics.Color(0xFF7C3AED),
    onPrimary = androidx.compose.ui.graphics.Color.White
)

@Composable
fun PointifyTheme(content: @Composable () -> Unit) {
    MaterialTheme(colorScheme = LightColors, content = content)
}
