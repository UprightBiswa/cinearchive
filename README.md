# CineArchive

CineArchive is a Flutter assignment starter that demonstrates paginated users, offline-first user creation, trending movies, movie details, offline bookmarking per user, silent retry handling, and background syncing.

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

## UI Flow

1. `UserListPage`
2. `AddUserPage`
3. `MovieListPage`
4. `MovieDetailPage`

## API Keys

Run the app with `dart-define` values:

```bash
flutter run --dart-define=REQRES_API_KEY=your_reqres_key --dart-define=TMDB_API_KEY=your_tmdb_key
```

### ReqRes

1. Visit the ReqRes dashboard/docs and generate or copy your API key.
2. Pass it as `REQRES_API_KEY`.

### TMDB

1. Visit `https://www.themoviedb.org/`
2. Sign in
3. Open `Settings -> API`
4. Request a key
5. Pass it as `TMDB_API_KEY`

## Offline Strategy

- Offline-created users are saved locally with a generated `localId`.
- Bookmarks are linked to the user's `localId`, so brand new offline users can immediately bookmark movies.
- When connectivity comes back, WorkManager triggers sync.
- Users sync first, then bookmarks are reconciled with the new remote user ID.

## Assumption

The assignment does not provide a bookmark sync API. This starter therefore treats bookmark sync as local relationship reconciliation after user sync. In a production app, that last step would POST bookmarks to your own backend.

## Network Resilience

The Dio interceptor intentionally fails 30% of GET requests once, retries with exponential backoff, and the UI shows a subtle `Reconnecting...` banner while retries happen in the background.

## Setup

```bash
flutter pub get
flutter run --dart-define=REQRES_API_KEY=your_reqres_key --dart-define=TMDB_API_KEY=your_tmdb_key
```

## Build APK

```bash
flutter build apk --dart-define=REQRES_API_KEY=your_reqres_key --dart-define=TMDB_API_KEY=your_tmdb_key
```
