package com.example.streak_it

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import android.view.View
import android.app.PendingIntent
import es.antonborri.home_widget.HomeWidgetPlugin

class StreakWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    private fun updateAppWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int
    ) {
        val widgetData = HomeWidgetPlugin.getData(context)
        val views = RemoteViews(context.packageName, R.layout.streak_widget)

        // Update streak count
        val streakCount = widgetData.getInt("streak_count", 0)
        val streakText = if (streakCount == 1) "$streakCount day" else "$streakCount days"
        views.setTextViewText(R.id.streak_count, "🔥 $streakText")

        // Update habit 1
        val habit1Name = widgetData.getString("habit_1_name", "Add your first habit")
        val habit1Icon = widgetData.getString("habit_1_icon", "✨")
        val habit1Done = widgetData.getBoolean("habit_1_done", false)
        views.setTextViewText(R.id.habit_1_name, habit1Name)
        views.setTextViewText(R.id.habit_1_icon, habit1Icon)
        views.setViewVisibility(R.id.habit_1_status, if (habit1Done) View.VISIBLE else View.GONE)

        // Update habit 2
        val habit2Name = widgetData.getString("habit_2_name", "")
        if (habit2Name?.isNotEmpty() == true) {
            val habit2Icon = widgetData.getString("habit_2_icon", "💪")
            val habit2Done = widgetData.getBoolean("habit_2_done", false)
            views.setTextViewText(R.id.habit_2_name, habit2Name)
            views.setTextViewText(R.id.habit_2_icon, habit2Icon)
            views.setViewVisibility(R.id.habit_2_status, if (habit2Done) View.VISIBLE else View.GONE)
            views.setViewVisibility(R.id.habit_2, View.VISIBLE)
        } else {
            views.setViewVisibility(R.id.habit_2, View.GONE)
        }

        // Update habit 3
        val habit3Name = widgetData.getString("habit_3_name", "")
        if (habit3Name?.isNotEmpty() == true) {
            val habit3Icon = widgetData.getString("habit_3_icon", "📚")
            val habit3Done = widgetData.getBoolean("habit_3_done", false)
            views.setTextViewText(R.id.habit_3_name, habit3Name)
            views.setTextViewText(R.id.habit_3_icon, habit3Icon)
            views.setViewVisibility(R.id.habit_3_status, if (habit3Done) View.VISIBLE else View.GONE)
            views.setViewVisibility(R.id.habit_3, View.VISIBLE)
        } else {
            views.setViewVisibility(R.id.habit_3, View.GONE)
        }

        // Set up click to open app
        val intent = Intent(context, MainActivity::class.java).apply {
            action = Intent.ACTION_MAIN
            addCategory(Intent.CATEGORY_LAUNCHER)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val pendingIntent = PendingIntent.getActivity(
            context,
            0,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        views.setOnClickPendingIntent(R.id.widget_title, pendingIntent)

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }
}
