package com.example.secura_ai

import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val channel = "ai_security/apps"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel).setMethodCallHandler { call, result ->
            if (call.method != "listApps") {
                result.notImplemented()
                return@setMethodCallHandler
            }
            val apps = packageManager.getInstalledApplications(PackageManager.GET_META_DATA).map { app ->
                val packageInfo = packageManager.getPackageInfo(app.packageName, 0)
                val permissions = packageManager.getPackageInfo(
                    app.packageName,
                    PackageManager.GET_PERMISSIONS
                ).requestedPermissions?.filter {
                    it.contains("SMS") || it.contains("PHONE") || it.contains("CONTACTS") ||
                        it.contains("RECORD_AUDIO") || it.contains("SYSTEM_ALERT_WINDOW") ||
                        it.contains("ACCESSIBILITY")
                } ?: emptyList()
                mapOf(
                    "name" to packageManager.getApplicationLabel(app).toString(),
                    "packageName" to app.packageName,
                    "version" to (packageInfo.versionName ?: "Unknown"),
                    "permissions" to permissions,
                    "systemApp" to ((app.flags and ApplicationInfo.FLAG_SYSTEM) != 0)
                )
            }.sortedBy { it["name"].toString().lowercase() }
            result.success(apps)
        }
    }
}
