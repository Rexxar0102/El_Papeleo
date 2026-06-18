package com.example.el_papeleo

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import androidx.core.app.NotificationCompat
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.MethodCall
import org.json.JSONObject

class NotificationHandler(private val context: Context) : MethodCallHandler {

    private val CHANNEL_ID = "sugerencias_estado"
    private val CHANNEL_NAME = "Cambios de estado"
    private val CHANNEL_DESC = "Notificaciones cuando tu sugerencia cambia de estado"
    private var flutterEngine: FlutterEngine? = null

    companion object {
        private const val CHANNEL = "el_papeleo/notifications"
        private const val NOTIFICATION_ID_BASE = 1000
    }

    fun registerWith(engine: FlutterEngine) {
        this.flutterEngine = engine
        MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler(this)
        createNotificationChannel()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                CHANNEL_NAME,
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = CHANNEL_DESC
                enableVibration(true)
            }
            val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            manager.createNotificationChannel(channel)
        }
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "initialize" -> {
                createNotificationChannel()
                result.success(true)
            }
            "showNotification" -> {
                val args = call.arguments as? Map<String, Any>
                val id = (args?.get("id") as? Int) ?: 0
                val title = args?.get("title") as? String ?: ""
                val body = args?.get("body") as? String ?: ""
                val payload = args?.get("payload") as? Map<String, Any>

                showNotification(id, title, body, payload)
                result.success(true)
            }
            else -> result.notImplemented()
        }
    }

    private fun showNotification(
        id: Int,
        title: String,
        body: String,
        payload: Map<String, Any>?
    ) {
        val intent = Intent(context, MainActivity::class.java).apply {
            action = Intent.ACTION_VIEW
            putExtra("notification_payload", JSONObject(payload).toString())
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }

        val pendingIntent = PendingIntent.getActivity(
            context,
            id,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val notification = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(context.applicationInfo.icon)
            .setContentTitle(title)
            .setContentText(body)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setAutoCancel(true)
            .setContentIntent(pendingIntent)
            .setVibrate(longArrayOf(0, 300, 200, 300))
            .build()

        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        manager.notify(NOTIFICATION_ID_BASE + id, notification)

        // Send callback to Flutter for navigation
        val engine = flutterEngine
        if (payload != null && engine != null) {
            val messenger = engine.dartExecutor.binaryMessenger
            val channel = MethodChannel(messenger, CHANNEL)
            channel.invokeMethod("onNotificationTap", payload)
        }
    }
}