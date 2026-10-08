# DUEX LAPINS MANAGER

Flutter Web-only administration draft.

## Run

```bash
flutter pub get
flutter run -d chrome
```

## Build

```bash
flutter build web --release
```

## Firebase Hosting

```bash
firebase init hosting
# public directory: build/web
# single-page app: Yes
firebase deploy --only hosting
```
