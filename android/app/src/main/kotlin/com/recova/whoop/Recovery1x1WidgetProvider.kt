package com.recova.whoop

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.graphics.Color
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class Recovery1x1WidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            try {
                val views = RemoteViews(context.packageName, R.layout.widget_recovery_1x1).apply {
                    val pendingIntent = Intent(context, MainActivity::class.java).let { intent ->
                        PendingIntent.getActivity(
                            context,
                            0,
                            intent,
                            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                        )
                    }
                    setOnClickPendingIntent(R.id.widget_recovery_1x1_container, pendingIntent)

                    val recovery = widgetData.getString("recovery_score", "--") ?: "--"
                    val status = widgetData.getString("recovery_status", "Awaiting sync") ?: "Awaiting sync"

                    val cleanRecovery = recovery.replace("%", "").trim()
                    setTextViewText(R.id.widget_recovery_1x1_value, cleanRecovery)
                    setTextViewText(R.id.widget_recovery_1x1_status, status)

                    val recNum = cleanRecovery.toIntOrNull()
                    val colorHex = when {
                        recNum == null -> "#8E92A0"
                        recNum >= 67 -> "#00F090"
                        recNum >= 34 -> "#FF9E00"
                        else -> "#FF3B56"
                    }
                    setTextColor(R.id.widget_recovery_1x1_value, Color.parseColor(colorHex))
                }
                appWidgetManager.updateAppWidget(widgetId, views)
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }
}
