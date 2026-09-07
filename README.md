# sahayogseva

## Run the backend

From the `backend` directory:

```powershell
$env:PYTHONPATH='.'
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000
```

The Flutter app uses `http://127.0.0.1:8000/api/v1` on desktop and
`http://10.0.2.2:8000/api/v1` on an Android emulator. For a physical device,
pass the computer's LAN address when starting Flutter:

```powershell
flutter run --dart-define=API_BASE_URL=http://<computer-lan-ip>:8000/api/v1
```

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
