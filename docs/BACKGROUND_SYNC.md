# Background Sync & Automatic Fetching Architecture

Recova implements a two-tier synchronization model for athletic recovery metrics:

1. **OS Background Daemon (WorkManager)**
   - Periodic background task registered under `com.recova.healthSync`.
   - Frequency: 30 minutes with an initial delay of 1 minute.
   - Separate background isolate dispatcher initializing `WidgetsFlutterBinding` and Drift/Health Connect platform channels.
   - Graceful skip if sync occurred within the last 10 minutes to preserve battery.

2. **In-App Foreground Lifecycle Synchronization**
   - Active foreground timer running every 30 minutes while the app remains open.
   - `WidgetsBindingObserver` monitoring `AppLifecycleState.resumed`: triggers an immediate delta sync if $\ge 30$ minutes have elapsed while the app was suspended.
   - Live relative timestamp updates on the Pulse home view and Profile Settings.
