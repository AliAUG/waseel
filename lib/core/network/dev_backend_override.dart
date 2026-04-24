/// Optional **dev** override for the RideGo API base URL.
///
/// Leave **`''`** (empty) to use [BackendConfig] defaults (127.0.0.1 / web host / Android emulator).
///
/// Set this **once** when the app runs on a **physical phone** or another machine and cannot
/// reach your computer at the default address — use your Mac/PC **LAN IP** and port **3000**:
///
/// ```dart
/// const String kDevBackendBaseUrlOverride = 'http://192.168.1.20:3000/api';
/// ```
///
/// Overrides are applied in order: `--dart-define=WASEEL_API_BASE=...` → this constant → platform defaults.
const String kDevBackendBaseUrlOverride = '';
