# Recova

Recova is a Flutter-based athletic recovery tracker designed for wearables that expose health data through Android Health Connect and iOS HealthKit. The app syncs health metrics, stores them locally using Drift, derives recovery-related signals that are not always exposed by the wearable itself, and presents them in a focused dashboard for readiness tracking.

This project is structured as an offline-first health analytics app with a clean architecture and background sync support.

## Why Recova

Many consumer wearables provide basic metrics such as heart rate, sleep, steps, and resting heart rate, but they often omit higher-level metrics like HRV, VO2 max, or recovery score. Recova bridges that gap by:

- reading the available wearable data from the platform health APIs
- persisting raw data locally for offline access
- computing derived metrics such as estimated VO2 max and composite recovery score
- surfacing trends across pulse, strain, recovery, and sleep
- syncing in the background when supported by the device

## Key features

- Health Connect / HealthKit data ingestion
- Offline-first local persistence with Drift
- Background synchronization using Workmanager
- Derived readiness metrics and baseline tracking
- Dashboard with tabs for pulse, recovery, strain, and sleep
- Material-based dark UI optimized for daily monitoring
- Permission handling for Android/iOS health access

## Architecture

The app follows a clean separation of concerns with BLoC/Cubit state management:

```text
lib/
├── core/            # app constants, theme, utilities, error handling
├── data/            # database, data sources, repositories, and DTO mapping
├── domain/          # entities, repository contracts, and business logic
├── presentation/    # Cubits, screens, reusable UI components
├── services/        # background sync jobs and OS integration
├── main.dart        # app bootstrap and provider setup
├── generated/       # generated Drift / codegen artifacts (if present)
assets/
└── ...
```

### Main app flow

- `main.dart` initializes the app and creates the shared repository + Blocs
- `HealthPlatformDatasource` handles access to the platform health APIs
- `AppDatabase` stores raw health records and derived metrics in a local SQLite database
- `DashboardCubit` aggregates the latest metrics for UI consumption
- `HealthSyncCubit` performs sync operations and refreshes the dashboard
- `MainShellScreen` hosts the app navigation and background sync notifications

## Supported health data and derived metrics

The app is designed around data that is commonly available from modern wearable APIs. In practice, the platform may provide some fields directly while requiring local estimation for others.

### Directly available data

| Metric | Typical availability | Source |
| --- | --- | --- |
| Heart rate | Yes | Health Connect / HealthKit |
| Resting heart rate | Yes | Health Connect / HealthKit |
| Sleep sessions | Yes | Health Connect / HealthKit |
| SpO2 / blood oxygen | Yes | Health Connect / HealthKit |
| Steps | Yes | Health Connect / HealthKit |
| Exercise sessions | Yes | Health Connect / HealthKit |
| Total calories burned | Yes | Health Connect / HealthKit |

### Computed locally

| Metric | Notes |
| --- | --- |
| Estimated VO2 max | Derived from HRmax vs HRrest using a simple formula |
| Recovery score | Weighted composite based on baseline deviation in resting heart rate, sleep, and oxygen levels |
| Strain / readiness indicators | Built from rolling trends and health baselines |

The project includes logic to estimate these values when the wearable does not directly expose them.

## Sync model

The project uses a background polling strategy because health platforms do not push updates to third-party apps in real time.

1. Background polling through `workmanager`
2. Manual sync via the dashboard
3. Delta-only sync based on a last-synced timestamp
4. Graceful fallback when background authorization is unavailable

This design allows the app to work even when direct push notifications are not supported by the platform.

## Local setup

### Prerequisites

- Flutter SDK (3.13+ recommended)
- Android Studio / Xcode depending on target platform
- Device or emulator with Health Connect / HealthKit access enabled

### Install and run

```bash
git clone https://github.com/himanksharma8434-coder/Recova.git
cd Recova
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

### Run checks

```bash
flutter test
flutter analyze
```

## Notes for Android users

The app requests permission to read health data and, on Android 14+, may also request background read authorization so that sync can continue outside the foreground session. The health permission flow is handled through the app's permission screen and repository layer.

## Repository layout highlights

- `lib/data/database`: Drift database schema and DAOs
- `lib/data/datasources`: platform adapters for wearable health APIs
- `lib/data/repositories`: repository implementations
- `lib/presentation/screens`: dashboard and metric detail screens
- `lib/presentation/cubits`: state management for health and UI flows
- `lib/services`: background task registration and sync scheduling

## Project status

This repository is a functional prototype / app in active development, focused on recovery analytics and wearable data processing. It is especially useful for Android Health Connect-based workflows and for users who want a custom readiness tracker based on locally derived metrics.

## License

This repository does not currently declare a project license in the root configuration. If you are planning to distribute or reuse the project, check whether the project owner intends to publish a license before doing so.

## Related note

The repository includes a nested `HCGateway-main` folder, which appears to be a separate reference/related project for Health Connect gateway integration. The main app logic for Recova is centered in the root `lib/` tree and is the area most relevant to this Flutter application.

---

This README was updated to match the repository's actual structure and functionality: a Flutter health analytics app built around health-sensor ingestion, offline-first persistence, recovery scoring, and background sync.
