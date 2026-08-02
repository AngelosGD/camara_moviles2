# camara_moviles2

Flutter app "Club Miembros" — register/search/report club members with photos, backed by local SQLite. All UI text is Spanish; keep it that way.

## Commands

```bash
flutter analyze        # lint (flutter_lints)
flutter test           # all tests
flutter test test/widget_test.dart   # single file
flutter run            # run on device/emulator
```

## Entrypoints

- `lib/main.dart` — `main()` runs `App(repository: SQLiteMemberRepository())`.
- `lib/app.dart` — root widget. `App` takes an optional `MemberRepository` (used to inject mocks in tests) and defaults to `SQLiteMemberRepository`.

## Architecture (layered)

- `lib/models/member.dart` — `Member` with `fromMap`/`toMap`; fields: `id`, `nombre`, `apellidos` (required), optional `telefono`, `email`, `fotoPath`, `fechaRegistro` (defaults to now).
- `lib/data/` — repository pattern: abstract `MemberRepository` (full CRUD: `insertMember`, `searchMembers`, `getAllMembers`, `updateMember`, `deleteMember`) + `SQLiteMemberRepository` (wraps `DatabaseHelper`) + `MockMemberRepository` (in-memory, for tests).
- `lib/data/database_helper.dart` — singleton `DatabaseHelper.instance`; table `miembros`, db file `camara_moviles2.db`.
- `lib/providers/member_provider.dart` — `MemberProvider extends ChangeNotifier`; UI talks only to the provider, never the DB.
- `lib/services/camera_service.dart` — `CameraService.savePhoto(XFile)` copies photo to private documents dir and returns the path string. Only the path is stored in DB (`fotoPath`), rendered with `Image.file`.
- `lib/screens/` — `HomeScreen` (BottomNavigationBar + `IndexedStack`, keeps tab state) hosting Register/Search/Report. `RegisterScreen` gets the photo two ways: pushes `CameraScreen` via Navigator (pops with the path), or `image_picker` gallery → both routed through `CameraService.savePhoto`.
- `lib/widgets/` — shared widgets used by screens: `PhotoPickerWidget`, `MemberCard`, `EmptyState`. New UI should reuse them.
- `lib/theme/app_theme.dart` — `AppTheme` static color palette + `lightTheme` (Material 3); screens/app use these colors/theme, not hard-coded values.

## Testing

- `test/widget_test.dart` is the only test — a smoke test pumping `App(repository: MockMemberRepository())`.
- Never use `SQLiteMemberRepository` (sqflite) or camera in widget tests; they don't work in the test environment. Inject `MockMemberRepository` via `App(repository: ...)`.

## Docs

- `BACKEND.md` and `FRONTEND.md` (Spanish) are the design specs. Code has diverged (e.g. gradle uses `flutter.minSdkVersion`, not the `minSdk = 21` in BACKEND.md) — trust the code.
- `Guia_Camara_y_QR_Flutter.docx` — professor's guide (camera + QR).

## Targets

Android (`android/`), Web (`web/`). Camera and sqflite don't run on web.
