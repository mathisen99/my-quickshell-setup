# my-quickshell-setup

#############################
######## Quickbar ###########
############################# 
bind = $mod, D, exec, qs ipc call shell toggleLauncher
bind = $mod, A, exec, qs ipc call shell toggleDashboard
bind = $mod, N, exec, qs ipc call shell toggleSidebar
bind = $mod, ESCAPE, exec, qs ipc call shell toggleSession
bind = $mod, W, exec, qs ipc call shell toggleWallpaper

exec-once = quickshell
