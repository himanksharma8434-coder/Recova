package com.recova.whoop

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class Vo2Rhr1x1WidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            try {
                val views = RemoteViews(context.packageName, R.layout.widget_vo2_rhr_1x1).apply {
                    val pendingIntent = Intent(context, MainActivity::class.java).let { intent ->
                        PendingIntent.getActivity(
                            context,
                            0,
                            intent,
                            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                        )
                    }
                    setOnClickPendingIntent(R.id.widget_vo2_rhr_1x1_container, pendingIntent)

                    val vo2 = widgetData.getString("vo2_max", "--") ?: "--"
                    val rhr = widgetData.getString("resting_hr", "--") ?: "--"
                    val cleanRhr = rhr.replace("bpm", "").trim()

                    setTextViewText(R.id.widget_vo2_value, vo2)
                    setTextViewText(R.id.widget_rhr_1x1_value, cleanRhr)
                }
                appWidgetManager.updateAppWidget(widgetId, views)
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }
}
