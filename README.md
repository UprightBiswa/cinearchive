# CineArchive

CineArchive is a Flutter assignment app with paginated users, offline-first user creation, movie browsing with OMDB, per-user offline bookmarks, retry handling, and background sync.

## Architecture

```text
lib/
  core/
  data/
  domain/
  presentation/
  services/
```

- State management: `flutter_bloc`
- Dependency injection: `get_it`
- Networking: `dio`
- Routing: `go_router`
- Local persistence: `hive`
- Background sync: `workmanager`
- Connectivity detection: `connectivity_plus`
- Image caching: `cached_network_image`

## API Setup

### ReqRes

The ReqRes key is currently hardcoded in [app_env.dart](d:/cineArchive/cinearchive/lib/core/config/app_env.dart) because this project is being prepared for assignment submission and you explicitly requested direct setup.

### OMDB

This project now uses OMDB instead of TMDB.

1. Open `https://www.omdbapi.com/apikey.aspx`
2. Select the free plan
3. Enter your email, first name, last name, and a short app description
4. Submit the form
5. Check your email and activate the key if OMDB sends a confirmation link
6. Run the app with:

```bash
flutter run --dart-define=OMDB_API_KEY=your_omdb_key
```

You can also keep the key in a local `env.json` file:

```json
{
  "OMDB_API_KEY": "your_omdb_key"
}
```

Run with:

```bash
flutter run --dart-define-from-file=env.json
```

## Offline Strategy

- Offline-created users are saved locally with a generated `localId`
- Bookmarks are linked to the user's `localId`
- A brand new offline user can open the movie flow and bookmark movies immediately
- When connectivity returns, WorkManager syncs pending users and keeps bookmark relationships intact

## Assumption

The assignment does not provide a bookmark sync API. This project therefore keeps bookmark persistence locally and reconciles user relationships after user sync.

## Network Resilience

The Dio interceptor intentionally fails 30% of GET requests once, retries with exponential backoff, and the UI shows a subtle reconnecting banner while retries happen in the background.

## Build APK

```bash
flutter build apk --dart-define=OMDB_API_KEY=your_omdb_key
```
