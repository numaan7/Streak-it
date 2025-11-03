package com.example.streak_it

import io.flutter.embedding.android.FlutterActivity
import android.os.Bundle
import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Create notification channels for Android 8.0+
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val notificationManager = getSystemService(NotificationManager::class.java)
            
            // Habit reminders channel
            val habitChannel = NotificationChannel(
                "habit_reminders",
                "Habit Reminders",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Reminders for your daily habits"
                enableVibration(true)
                enableLights(true)
            }
            notificationManager.createNotificationChannel(habitChannel)
            
            // Morning reminders channel
            val morningChannel = NotificationChannel(
                "morning_reminders",
                "Morning Reminders",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Morning reminders when you wake up"
                enableVibration(true)
                enableLights(true)
            }
            notificationManager.createNotificationChannel(morningChannel)
        }
    }
}
