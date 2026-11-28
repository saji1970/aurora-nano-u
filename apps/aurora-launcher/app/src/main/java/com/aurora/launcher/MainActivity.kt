package com.aurora.launcher

import android.content.Intent
import android.os.Bundle
import android.view.KeyEvent
import androidx.activity.ComponentActivity
import androidx.activity.addCallback
import androidx.activity.compose.setContent
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.produceState
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import kotlinx.coroutines.delay
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

/**
 * Aurora glasses launcher, starter version.
 *
 * Glasses rules built in:
 *  - black everywhere: on a see-through display black is transparent, so only text and outlines show;
 *  - everything is reachable with five inputs: DPAD left/right/up/down and DPAD_CENTER (select),
 *    plus BACK. The temple touchpad is mapped to these keys in the board's key layout, and the
 *    emulator's arrow keys and Enter do the same;
 *  - the display fades after a few seconds without input, to save battery, and any input wakes it.
 */
class MainActivity : ComponentActivity() {

    private val state = LauncherState()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        state.apps = loadLaunchableApps()

        onBackPressedDispatcher.addCallback(this) {
            state.touch()
            state.back()   // on the home row, BACK does nothing: a launcher never closes
        }

        setContent { LauncherScreen(state, onLaunch = ::launch) }
    }

    // Keys are handled here, before Compose's own focus system sees them, so the touchpad
    // (mapped to DPAD keys) always drives the launcher's selection.
    override fun dispatchKeyEvent(event: KeyEvent): Boolean {
        if (event.action == KeyEvent.ACTION_DOWN) {
            val handled = when (event.keyCode) {
                KeyEvent.KEYCODE_DPAD_RIGHT, KeyEvent.KEYCODE_DPAD_DOWN -> state.move(+1)
                KeyEvent.KEYCODE_DPAD_LEFT, KeyEvent.KEYCODE_DPAD_UP -> state.move(-1)
                KeyEvent.KEYCODE_DPAD_CENTER, KeyEvent.KEYCODE_ENTER -> state.select(::launch)
                else -> false
            }
            state.touch()
            if (handled) return true
        }
        return super.dispatchKeyEvent(event)
    }

    private fun loadLaunchableApps(): List<AppEntry> {
        val intent = Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_LAUNCHER)
        return packageManager.queryIntentActivities(intent, 0)
            .filter { it.activityInfo.packageName != packageName }
            .map { AppEntry(it.loadLabel(packageManager).toString(), it.activityInfo.packageName) }
            .sortedBy { it.label.lowercase() }
    }

    private fun launch(app: AppEntry) {
        packageManager.getLaunchIntentForPackage(app.packageName)?.let { startActivity(it) }
    }
}

data class Card(val title: String, val hint: String)

data class AppEntry(val label: String, val packageName: String)

/** The launch apps from docs/glasses-software-platform.md. Each opens a placeholder screen for now. */
val HOME_CARDS = listOf(
    Card("Assistant", "Ask anything. Say \"Hey Aurora\""),
    Card("Camera", "Photo or 3-minute clip. The privacy light is always on while recording"),
    Card("Captions", "Live subtitles and translation"),
    Card("Navigate", "Walking and cycling directions"),
    Card("Messages", "Notifications from your phone"),
    Card("Notes", "Teleprompter and voice notes"),
    Card("Music", "Open-ear audio"),
    Card("Apps", "All installed Android apps"),
)

class LauncherState {
    var apps: List<AppEntry> = emptyList()
    var selected by mutableIntStateOf(0)
    var openCard by mutableStateOf<Card?>(null)
    var appIndex by mutableIntStateOf(0)
    var inputCount by mutableIntStateOf(0)
    var dimmed by mutableStateOf(false)

    fun touch() {
        inputCount++
        dimmed = false
    }

    fun move(step: Int): Boolean {
        val card = openCard
        if (card == null) {
            selected = (selected + step).mod(HOME_CARDS.size)
        } else if (card.title == "Apps" && apps.isNotEmpty()) {
            appIndex = (appIndex + step).coerceIn(0, apps.size - 1)
        }
        return true
    }

    fun select(launch: (AppEntry) -> Unit): Boolean {
        val card = openCard
        when {
            card == null -> { openCard = HOME_CARDS[selected]; appIndex = 0 }
            card.title == "Apps" && apps.isNotEmpty() -> launch(apps[appIndex])
        }
        return true
    }

    fun back() {
        openCard = null
    }
}

private val Bright = Color(0xFFEAF4FF)
private val Muted = Color(0xFF7F95AA)
private val Accent = Color(0xFF5BC8FF)

@Composable
fun LauncherScreen(state: LauncherState, onLaunch: (AppEntry) -> Unit) {
    // Fade the whole display after 8 s without input; any key brings it back.
    LaunchedEffect(state.inputCount) {
        delay(8_000)
        state.dimmed = true
    }
    val alpha by animateFloatAsState(if (state.dimmed) 0.12f else 1f, tween(600), label = "fade")

    Box(
        Modifier
            .fillMaxSize()
            .background(Color.Black)
            .alpha(alpha)
            .padding(horizontal = 32.dp, vertical = 24.dp)
    ) {
        val card = state.openCard
        if (card == null) HomeRow(state) else CardScreen(card, state, onLaunch)
    }
}

@Composable
private fun Clock() {
    val time by produceState(initialValue = "") {
        val fmt = SimpleDateFormat("HH:mm", Locale.getDefault())
        while (true) {
            value = fmt.format(Date())
            delay(10_000)
        }
    }
    Text(time, color = Bright, fontSize = 40.sp, fontWeight = FontWeight.Light)
}

@Composable
private fun HomeRow(state: LauncherState) {
    val listState = rememberLazyListState()
    LaunchedEffect(state.selected) { listState.animateScrollToItem(state.selected) }

    Column(Modifier.fillMaxSize(), verticalArrangement = Arrangement.SpaceBetween) {
        Clock()
        LazyRow(state = listState, horizontalArrangement = Arrangement.spacedBy(16.dp)) {
            itemsIndexed(HOME_CARDS) { i, card ->
                val focused = i == state.selected
                Box(
                    Modifier
                        .size(width = 180.dp, height = 120.dp)
                        .border(
                            width = if (focused) 3.dp else 1.dp,
                            color = if (focused) Accent else Muted.copy(alpha = 0.5f),
                            shape = RoundedCornerShape(18.dp)
                        )
                        .clickable { state.touch(); state.selected = i; state.openCard = card }
                        .padding(16.dp),
                    contentAlignment = Alignment.BottomStart
                ) {
                    Text(
                        card.title,
                        color = if (focused) Bright else Muted,
                        fontSize = 24.sp,
                        fontWeight = FontWeight.SemiBold
                    )
                }
            }
        }
        Text(
            HOME_CARDS[state.selected].hint,
            color = Muted,
            fontSize = 18.sp
        )
    }
}

@Composable
private fun CardScreen(card: Card, state: LauncherState, onLaunch: (AppEntry) -> Unit) {
    Column(Modifier.fillMaxSize()) {
        Text(card.title, color = Bright, fontSize = 32.sp, fontWeight = FontWeight.SemiBold)
        Spacer(Modifier.height(12.dp))
        if (card.title == "Apps") {
            AppList(state, onLaunch)
        } else {
            Text(card.hint, color = Muted, fontSize = 20.sp)
            Spacer(Modifier.height(24.dp))
            Text("Coming soon. Press back to return.", color = Muted, fontSize = 16.sp)
        }
    }
}

@Composable
private fun AppList(state: LauncherState, onLaunch: (AppEntry) -> Unit) {
    if (state.apps.isEmpty()) {
        Text("No other apps installed.", color = Muted, fontSize = 18.sp)
        return
    }
    val listState = rememberLazyListState()
    LaunchedEffect(state.appIndex) { listState.animateScrollToItem(maxOf(0, state.appIndex - 2)) }
    LazyColumn(state = listState, verticalArrangement = Arrangement.spacedBy(6.dp)) {
        itemsIndexed(state.apps) { i, app ->
            val focused = i == state.appIndex
            Row(
                Modifier
                    .fillMaxWidth()
                    .border(
                        width = if (focused) 2.dp else 0.dp,
                        color = if (focused) Accent else Color.Transparent,
                        shape = RoundedCornerShape(10.dp)
                    )
                    .clickable { state.touch(); state.appIndex = i; onLaunch(app) }
                    .padding(horizontal = 14.dp, vertical = 8.dp)
            ) {
                Text(app.label, color = if (focused) Bright else Muted, fontSize = 20.sp)
            }
        }
    }
}
