package com.example.dynamic_app_icon.dynamic_app_icon

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.content.pm.ResolveInfo
import android.os.Build
import android.util.Log

/**
 * Manages the switching, enabling, and disabling of Android launcher components
 * (<activity-alias> and <activity>) dynamically at runtime.
 *
 * Implements clean, reusable, and dynamic lookups via Android's [PackageManager]
 * to support unlimited predefined alternate icons without hardcoding components.
 */
class IconManager(private val context: Context) {

    private val packageManager: PackageManager = context.packageManager
    private val packageName: String = context.packageName

    companion object {
        private const val TAG = "IconManager"
        private const val PREFS_NAME = "dynamic_app_icon_prefs"
        private const val KEY_CURRENT_ICON = "current_icon_name"
        private const val DEFAULT_ICON_NAME = "default"
    }

    /**
     * Retrieves all launcher components declared in the manifest for this application.
     * Includes both enabled and disabled components (activities and activity-aliases).
     */
    private fun getLauncherComponents(): List<ResolveInfo> {
        val intent = Intent(Intent.ACTION_MAIN).apply {
            addCategory(Intent.CATEGORY_LAUNCHER)
            setPackage(packageName)
        }

        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            packageManager.queryIntentActivities(
                intent,
                PackageManager.ResolveInfoFlags.of(PackageManager.MATCH_DISABLED_COMPONENTS.toLong())
            )
        } else {
            @Suppress("DEPRECATION")
            packageManager.queryIntentActivities(intent, PackageManager.MATCH_DISABLED_COMPONENTS)
        }
    }

    /**
     * Determines which launcher component is the default/primary entry point.
     * The default entry point is the one declared as `enabled="true"` in the compile-time APK manifest.
     */
    private fun getDefaultComponent(components: List<ResolveInfo>): ResolveInfo? {
        // In clean manifests, alternate icons are initially disabled, and only the default is enabled.
        return components.find { it.activityInfo.enabled }
    }

    /**
     * Toggles launcher components to enable the alternate icon matching [iconName].
     *
     * @param iconName Simple suffix or class sub-name matching the desired launcher component.
     * @throws IllegalArgumentException if the requested icon name cannot be resolved to any manifest alias.
     */
    fun changeIcon(iconName: String) {
        val components = getLauncherComponents()
        if (components.isEmpty()) {
            throw IllegalStateException("No launcher components found in manifest.")
        }

        // Match based on endsWith (e.g. "dark_icon" matches ".MainActivityDarkIcon" or ".dark_icon")
        val target = components.find {
            it.activityInfo.name.endsWith(iconName, ignoreCase = true) ||
            it.activityInfo.name.substringAfterLast(".").equals(iconName, ignoreCase = true)
        } ?: throw IllegalArgumentException("No alternate launcher activity-alias found matching: $iconName")

        val targetName = target.activityInfo.name

        // 1. Enable the targeted handler first (to prevent a temporary missing icon state)
        packageManager.setComponentEnabledSetting(
            ComponentName(packageName, targetName),
            PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
            PackageManager.DONT_KILL_APP
        )

        // 2. Disable all other options
        for (component in components) {
            val name = component.activityInfo.name
            if (name != targetName) {
                packageManager.setComponentEnabledSetting(
                    ComponentName(packageName, name),
                    PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
                    PackageManager.DONT_KILL_APP
                )
            }
        }

        // Save selected state
        persistCurrentIcon(iconName)
        Log.d(TAG, "Toggled active launcher component to: $targetName")
    }

    /**
     * Disables all alternate aliases and restores the default/primary manifest launcher component.
     */
    fun resetToDefault() {
        val components = getLauncherComponents()
        val defaultComponent = getDefaultComponent(components) 
            ?: throw IllegalStateException("Could not identify the default launcher component (enabled by default in manifest).")

        val defaultName = defaultComponent.activityInfo.name

        // Enable default
        packageManager.setComponentEnabledSetting(
            ComponentName(packageName, defaultName),
            PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
            PackageManager.DONT_KILL_APP
        )

        // Disable all alternates
        for (component in components) {
            val name = component.activityInfo.name
            if (name != defaultName) {
                packageManager.setComponentEnabledSetting(
                    ComponentName(packageName, name),
                    PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
                    PackageManager.DONT_KILL_APP
                )
            }
        }

        // Save state as default
        persistCurrentIcon(DEFAULT_ICON_NAME)
        Log.d(TAG, "Reset launcher to primary default: $defaultName")
    }

    /**
     * Checks if the dynamic icon components are supported on this environment.
     */
    fun isSupported(): Boolean {
        // Launcher activity alias manipulation is supported on all standard Android versions (API 1+).
        // Since minSdkVersion is 26 (Android 8+), this is always true.
        return true
    }

    /**
     * Retrieves the current active icon name.
     * Fallback checks the OS state if SharedPreferences is not set.
     */
    fun getCurrentIcon(): String {
        val savedIcon = getPrefs().getString(KEY_CURRENT_ICON, null)
        if (savedIcon != null) {
            return savedIcon
        }

        // Dynamic State Fallback: query what's currently enabled.
        val components = getLauncherComponents()
        val defaultComponent = getDefaultComponent(components)

        val active = components.find { component ->
            val name = component.activityInfo.name
            val state = packageManager.getComponentEnabledSetting(ComponentName(packageName, name))
            when (state) {
                PackageManager.COMPONENT_ENABLED_STATE_ENABLED -> true
                PackageManager.COMPONENT_ENABLED_STATE_DISABLED -> false
                else -> component.activityInfo.enabled // Get manifest static flag
            }
        }

        if (active == null || active.activityInfo.name == defaultComponent?.activityInfo?.name) {
            return DEFAULT_ICON_NAME
        }

        // Return simple name: dot-trimmed text suffix
        return active.activityInfo.name.substringAfterLast(".")
    }

    /**
     * Lists all alternate app icons available for switching (all options excluding default launcher).
     */
    fun getAvailableIcons(): List<String> {
        val components = getLauncherComponents()
        val defaultComponent = getDefaultComponent(components)

        return components
            .filter { it.activityInfo.name != defaultComponent?.activityInfo?.name }
            .map { it.activityInfo.name.substringAfterLast(".") }
    }

    private fun persistCurrentIcon(name: String) {
        getPrefs().edit().putString(KEY_CURRENT_ICON, name).apply()
    }

    private fun getPrefs() = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
}
