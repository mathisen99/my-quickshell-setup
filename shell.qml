//@ pragma UseQApplication
import Quickshell
import Quickshell.Io
import QtQuick
import "theme"
import "bar"
import "popups"

ShellRoot {
    id: shell
    
    Theme { id: theme }
    
    // Global state
    property bool dndEnabled: false
    
    // Expose popup references globally
    property alias dashboardPopup: dashboard
    property alias sidebarPopup: sidebar
    property alias sessionPopup: session
    property alias launcherPopup: launcher
    property alias settingsPopup: settings
    property alias wallpaperPopup: wallpaper
    
    // IPC handler for keybinds
    IpcHandler {
        target: "shell"
        
        function toggleLauncher(): void { launcher.toggle() }
        function toggleDashboard(): void { dashboard.toggle() }
        function toggleSidebar(): void { sidebar.toggle() }
        function toggleSession(): void { session.toggle() }
        function toggleSettings(): void { settings.toggle() }
        function toggleWallpaper(): void { wallpaper.toggle() }
    }
    
    Bar {}
    
    DashboardPopup { id: dashboard }
    SidebarPopup { id: sidebar; notifHistory: notifPopup.history }
    SessionPopup { id: session }
    NotificationPopup { id: notifPopup; dndEnabled: shell.dndEnabled }
    LauncherPopup { id: launcher }
    SettingsPopup { id: settings }
    WallpaperPopup { id: wallpaper }
}
