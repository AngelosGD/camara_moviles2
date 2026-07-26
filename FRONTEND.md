# FRONTEND — Diseño, pantallas y navegación

## Estructura de carpetas (UI)

Dentro de `lib/`, todo lo visual va aquí:

```
lib/
├── main.dart                    # Punto de entrada, configura proveedores y rutas
├── app.dart                     # Widget raíz MaterialApp con tema y rutas
├── screens/
│   ├── home_screen.dart         # Pantalla principal con BottomNavigationBar
│   ├── register_screen.dart     # Formulario de registro
│   ├── search_screen.dart       # Búsqueda por nombre
│   └── report_screen.dart       # Reporte de todos los miembros
├── widgets/
│   ├── member_card.dart         # Tarjeta para mostrar un miembro en listas
│   ├── photo_picker_widget.dart # Preview de foto + botón de captura
│   └── empty_state.dart         # Widget para cuando no hay datos
└── theme/
    └── app_theme.dart           # Colores, tipografía, estilos globales
```

## Navegación

### Estructura general

```
MaterialApp
 └── HomeScreen (BottomNavigationBar)
       ├── [0] RegisterScreen   — "Registrar"
       ├── [1] SearchScreen     — "Buscar"
       └── [2] ReportScreen     — "Reporte"
```

Usa un `BottomNavigationBar` con 3 ítems. Cada tab mantiene su estado con `IndexedStack` para no perder datos al cambiar de pestaña.

Si prefieren usar `Navigator` con rutas nombradas:

| Ruta                     | Pantalla        |
|--------------------------|-----------------|
| `/`                      | HomeScreen      |
| `/register`              | RegisterScreen  |
| `/search`                | SearchScreen    |
| `/report`                | ReportScreen    |
| `/member-detail/:id`     | MemberDetailScreen (opcional) |

## Pantallas

### 1. RegisterScreen — Registrar miembro

```
┌──────────────────────────────┐
│  AppBar: "Registrar Miembro" │
├──────────────────────────────┤
│                              │
│     ┌──────────────────┐     │
│     │   Foto preview    │     │
│     │   (circular)      │     │
│     └──────────────────┘     │
│     [📷 Tomar Foto]          │
│                              │
│   Nombre *                   │
│   ┌──────────────────────┐   │
│   │                      │   │
│   └──────────────────────┘   │
│                              │
│   Apellidos *                │
│   ┌──────────────────────┐   │
│   │                      │   │
│   └──────────────────────┘   │
│                              │
│   Teléfono                   │
│   ┌──────────────────────┐   │
│   │                      │   │
│   └──────────────────────┘   │
│                              │
│   Email                      │
│   ┌──────────────────────┐   │
│   │                      │   │
│   └──────────────────────┘   │
│                              │
│  ┌────────────────────────┐  │
│  │   GUARDAR MIEMBRO      │  │
│  └────────────────────────┘  │
│                              │
└──────────────────────────────┘
```

- Foto preview: `CircleAvatar` con la foto tomada o un icono por defecto.
- Botón "Tomar Foto": llama a la cámara del backend.
- Campos marcados con * son obligatorios. Validación básica.
- Al guardar, muestra un `SnackBar` de éxito/error y limpia el formulario.

### 2. SearchScreen — Buscar por nombre

```
┌──────────────────────────────┐
│  AppBar: "Buscar Miembro"    │
├──────────────────────────────┤
│                              │
│   🔍  ┌──────────────────┐  │
│       │  Nombre a buscar  │  │
│       └──────────────────┘  │
│                              │
│   ┌────────────────────────┐ │
│   │       BUSCAR           │ │
│   └────────────────────────┘ │
│                              │
│   ── Resultado ──            │
│                              │
│   ┌──────────────────────┐   │
│   │ 🧑  Juan Pérez       │   │
│   │     Tel: 555-1234    │   │
│   │     juan@mail.com    │   │
│   │     Registrado: ...  │   │
│   └──────────────────────┘   │
│                              │
│   o "No se encontró miembro" │
│                              │
└──────────────────────────────┘
```

- Input de búsqueda con botón.
- Al presionar buscar, se llama al provider `searchByName(nombre)`.
- Muestra la tarjeta con los datos del miembro y su foto si se encuentra.
- Si no hay resultados, muestra un `EmptyState` con mensaje.

### 3. ReportScreen — Lista de todos los miembros

```
┌──────────────────────────────┐
│  AppBar: "Todos los Miembros"│
├──────────────────────────────┤
│                              │
│  ┌────────────────────────┐  │
│  │ 🧑  Juan Pérez         │  │
│  │     📅 dd/mm/aaaa      │  │
│  └────────────────────────┘  │
│  ┌────────────────────────┐  │
│  │ 🧑  María García       │  │
│  │     📅 dd/mm/aaaa      │  │
│  └────────────────────────┘  │
│  ┌────────────────────────┐  │
│  │ 🧑  Carlos López       │  │
│  │     📅 dd/mm/aaaa      │  │
│  └────────────────────────┘  │
│           ...                │
│                              │
└──────────────────────────────┘
```

- `ListView.builder` con tarjetas de miembros.
- Cada tarjeta (`MemberCard`) muestra: foto thumbnail, nombre completo, fecha de registro.
- Opcional: pull-to-refresh para recargar.
- Si no hay miembros, mostrar `EmptyState` con "Aún no hay miembros registrados".

## Tema / Estilos

En `lib/theme/app_theme.dart`:

```dart
class AppTheme {
  static ThemeData get lightTheme => ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
    // Personaliza según el diseño que quieran
  );
}
```

Pueden cambiar el `seedColor` para darle identidad propia a la app del club.

## Cómo trabajar sin el backend (mock data)

El integrante de frontend puede trabajar independientemente si el backend expone un **MockMemberProvider**:

1. El backend define una interfaz/proveedor.
2. El frontend solo consume el provider (no sabe si es real o mock).
3. El backend entrega un provider mock con datos quemados.

O, más simple: en tu `main.dart`, mientras esperas al backend, inyecta datos quemados tú mismo:

```dart
// Temporal — reemplazar cuando el backend esté listo
class MockMemberProvider extends ChangeNotifier {
  List<Member> _members = [
    Member(nombre: 'Juan', apellidos: 'Pérez', ...),
    Member(nombre: 'María', apellidos: 'García', ...),
  ];

  Future<void> loadMembers() async {
    notifyListeners();
  }

  Future<Member?> searchByName(String nombre) async {
    return _members.firstWhere(
      (m) => m.nombre.toLowerCase().contains(nombre.toLowerCase()),
      orElse: () => null as Member,
    );
  }
}
```

En `main.dart` usas `ChangeNotifierProvider<MemberProvider>` y cambias la implementación cuando el backend la entregue.

## Resumen de widgets que creas (frontend)

| Widget              | Ubicación                    | Propósito                        |
|---------------------|------------------------------|----------------------------------|
| `PhotoPickerWidget` | `widgets/`                   | Preview circular + botón cámara  |
| `MemberCard`        | `widgets/`                   | Tarjeta para listas de miembros  |
| `EmptyState`        | `widgets/`                   | Mensaje cuando no hay datos      |
| `AppTheme`          | `theme/`                     | Configuración visual global      |

## Resumen de pantallas

| Screen            | Ruta             | BottomNav | Propósito                        |
|-------------------|------------------|-----------|----------------------------------|
| RegisterScreen    | `/register`      | 0         | Formulario + foto + guardar      |
| SearchScreen      | `/search`        | 1         | Buscar por nombre + mostrar      |
| ReportScreen      | `/report`        | 2         | Lista completa de miembros       |

## Notas para el frontend

- No pongas lógica de base de datos ni de cámara en tus widgets. Llama al provider, él hace todo.
- Diseña primero los 3 mockups en código (usando datos mock) y después conectas los providers reales.
- La navegación con BottomNavigationBar es la más rápida de implementar. Si quieren drawer + rutas también funciona.
- Usa `const` widgets donde puedas para mejor rendimiento.
