package com.recova.whoop

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.graphics.Color
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class RecoveryRhrWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_recovery_rhr).apply {
                // Pending intent to launch app on widget tap
                val pendingIntent = Intent(context, MainActivity::class.java).let { intent ->
                    PendingIntent.getActivity(
                        context,
                        0,
                        intent,
                        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                    )
                }
                setOnClickPendingIntent(R.id.widget_container, pendingIntent)

                val recovery = widgetData.getString("recovery_score", "--") ?: "--"
                val status = widgetData.getString("recovery_status", "Awaiting Sync") ?: "Awaiting Sync"
                val rhr = widgetData.getString("resting_hr", "--") ?: "--"
                val delta = widgetData.getString("rhr_delta", "Basal") ?: "Basal"
                val lastUpdated = widgetData.getString("last_updated", "Auto 30m • Tap to open") ?: "Auto 30m • Tap to open"

                setTextViewText(R.id.widget_recovery_value, recovery)
                setTextViewText(R.id.widget_recovery_status, status)
                setTextViewText(R.id.widget_rhr_value, rhr)
                setTextViewText(R.id.widget_rhr_delta, delta)
                setTextViewText(R.id.widget_last_updated, lastUpdated)

                // Dynamic coloring for recovery score (Emerald / Amber / Crimson)
                val recNum = recovery.replace("%", "").trim().toIntOrNull()
                val colorHex = when {
                    recNum == null -> "#8E92A0"
                    recNum >= 67 -> "#00F090"
                    recNum >= 34 -> "#FF9E00"
                    else -> "#FF3B56"
                }
                setTextColor(R.id.widget_recovery_value, Color.parseColor(colorHex))
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
