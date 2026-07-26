# BACKEND — Lógica de negocio y datos

## Arquitectura general

Dentro del mismo proyecto Flutter, el "backend" es la capa que maneja datos, cámara y estado. El frontend (UI) llama a providers/servicios que tú expones, sin conocer la implementación interna.

## Dependencias que vas a agregar a `pubspec.yaml`

Basado en la guía del profe (`Guia_Camara_y_QR_Flutter.docx`) más lo que pide el proyecto:

```yaml
dependencies:
  camera: ^0.10.5+9
  path_provider: ^2.1.2
  sqflite: ^2.3.0
  provider: ^6.1.1
```

- `camera` — para tomar la foto del miembro
- `path_provider` — para guardar las fotos en disco
- `sqflite` — base de datos SQLite local
- `provider` — para exponer el estado a la UI (pueden cambiarlo por Riverpod si prefieren)

### Configuración de plataforma nativa

**Android** — En `android/app/build.gradle.kts`:
```kotlin
android {
    defaultConfig {
        minSdk = 21
    }
}
```

**iOS** — En `ios/Runner/Info.plist` (cuando tengan target iOS):
```xml
<key>NSCameraUsageDescription</key>
<string>Esta aplicación requiere acceso a la cámara para tomar fotos de los miembros.</string>
```

## Modelo de datos

### Member

| Campo       | Tipo     | Notas                                 |
|-------------|----------|---------------------------------------|
| id          | int      | PK, autoincremental                   |
| nombre      | String   | Único para búsqueda                   |
| apellidos   | String   |                                       |
| telefono    | String   | Opcional                              |
| email       | String   | Opcional                              |
| fotoPath    | String   | Ruta local de la imagen (no el byte[])|
| fechaRegistro | String | ISO 8601, generado automáticamente    |

```dart
class Member {
  final int? id;
  final String nombre;
  final String apellidos;
  final String? telefono;
  final String? email;
  final String? fotoPath;
  final DateTime fechaRegistro;

  // constructor, fromMap, toMap, toJson
}
```

## Capa de base de datos (SQLite)

Crear archivo: `lib/data/database_helper.dart`

- Singleton o instancia única.
- Métodos: `initDB()`, `insertMember(Member)`, `getMemberByName(String)`, `getAllMembers()`, `updateMember(Member)`, `deleteMember(int id)`.
- La tabla se llama `miembros`.

## Capa de repositorio

`lib/data/member_repository.dart`

Interfaz abstracta que la UI nunca toca directamente, solo a través de providers:

```dart
abstract class MemberRepository {
  Future<int> insertMember(Member member);
  Future<Member?> getMemberByName(String nombre);
  Future<List<Member>> getAllMembers();
  Future<int> updateMember(Member member);
  Future<int> deleteMember(int id);
}
```

Implementación concreta: `SQLiteMemberRepository` usa `DatabaseHelper`.

## Lógica de cámara y foto

Basado en la guía del profe, sección 2.4:

- Inicializar `CameraController` con `ResolutionPreset.medium` (buen balance calidad/rendimiento).
- Al tomar la foto: usar `_controller!.takePicture()` → devuelve `XFile`.
- Guardar la foto en el directorio de la app: `path_provider` + `getApplicationDocumentsDirectory()`.
- Almacenar en el modelo solo el `fotoPath` (string de ruta), no el binario en SQLite.
- La UI va a leer la foto con `Image.file(File(member.fotoPath))`.

## Exposición a la UI (Provider)

`lib/providers/member_provider.dart`

```dart
class MemberProvider extends ChangeNotifier {
  final MemberRepository _repository;

  // Estado
  List<Member> _members = [];
  Member? _selectedMember;
  bool _isLoading = false;

  // Métodos expuestos
  Future<void> loadMembers();
  Future<void> registerMember(Member member, XFile? photoFile);
  Future<Member?> searchByName(String nombre);
  Future<void> deleteMember(int id);
}
```

### Lo que el frontend espera de ti

| Provider method        | Propósito                      |
|------------------------|--------------------------------|
| `loadMembers()`        | Cargar todos los miembros      |
| `registerMember(...)`  | Registrar nuevo miembro + foto|
| `searchByName(String)` | Buscar por nombre exacto/aprox |
| `members` (getter)     | Lista actual de miembros       |
| `selectedMember`       | Último resultado de búsqueda   |
| `isLoading`            | Indicador de carga             |

## Resumen de archivos que deberías crear

```
lib/
├── models/
│   └── member.dart
├── data/
│   ├── database_helper.dart
│   └── member_repository.dart
├── services/
│   └── camera_service.dart       (opcional, encapsular cámara)
├── providers/
│   └── member_provider.dart
```

## Notas

- No mezcles lógica de UI en tus archivos. Todo lo que toque `BuildContext` o widgets es del frontend.
- Si el frontend necesita mock data para trabajar sin ti, expón un `MockMemberRepository` que devuelva datos fake.
- La guía del profe tiene ejemplo completo de cámara + ML Kit. Acá solo ocupas la cámara (foto), el QR no es necesario para este proyecto a menos que quieran agregarlo como extra.
