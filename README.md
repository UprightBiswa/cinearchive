# CineArchive

CineArchive is a Flutter assignment app that demonstrates paginated user listing, offline-first user creation, movie browsing, per-user bookmarks, retry handling, and background synchronization.

## Features Implemented
- Paginated user list from ReqRes
- Online and offline user creation
- Per-user movie browsing
- Movie detail screen
- Offline bookmark support
- Background sync using WorkManager
- Retry handling with exponential backoff
- Reconnecting UI indicator for failed paginated GET requests

## Architecture
lib/
  core/
  data/
  domain/
  presentation/
  services/

## Tech Stack
- State management: flutter_bloc
- Dependency injection: get_it
- Networking: dio
- Routing: go_router
- Local persistence: hive
- Background sync: workmanager
- Connectivity detection: connectivity_plus
- Image caching: cached_network_image

## API Setup

### ReqRes
ReqRes is used for user listing and user creation.

### OMDB
OMDB is used for movie listing/detail as an allowed fallback movie API for this assignment.

To run:
```bash
flutter run