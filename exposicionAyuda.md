# Ayuda de la exposición — Club Miembros

App "Club Miembros": registrar/buscar/reportar miembros con foto. Todo es **local**: la imagen se guarda en la carpeta del teléfono y los datos en **SQLite** embebido. Nada de Firebase ni servicios externos.

Los puntos van en el orden que pide el profesor.

---

## Punto 1 — Dependencias utilizadas

En el `pubspec.yaml`:

```yaml
camera: ^0.12.0+2
image_picker: ^1.2.3
path_provider: ^2.1.6
path: ^1.9.1
sqflite: ^2.4.2+1
provider: ^6.1.5+1
```

- **camera** → toma la foto con la cámara del teléfono.
- **image_picker** → también podemos escoger una foto de la galería.
- **path_provider** → nos da la carpeta de la app donde se guarda la imagen.
- **path** → arma/une las rutas de archivos.
- **sqflite** → base de datos SQLite local.
- **provider** → manejar el estado (avisa a la pantalla cuando cambian los datos).

Además `flutter_test` (para los tests) y `flutter_lints` (reglas del `flutter analyze`).

**Para la exposición al grupo:**
> Para la foto usamos `camera` + `image_picker`, para guardarla `path_provider` + `path`, para los datos `sqflite`, y `provider` para el estado. Todo es local, sin Firebase.

---

## Punto 2 — Inicialización de la cámara

```dart
final cameras = await availableCameras();                 // cámaras del teléfono
final initial = cameras.firstWhere(                        // elegimos la trasera
  (c) => c.lensDirection == CameraLensDirection.back,
  orElse: () => cameras.first,
);
final controller = CameraController(initial, ResolutionPreset.medium);
await controller.initialize();                            // encender la cámara
```

- `availableCameras()` → lista de cámaras del teléfono.
- Elegimos la **trasera**, y si no hay, la primera.
- `CameraController` con **resolución media**.
- `await controller.initialize()` → enciende la cámara y nos esperamos a que esté lista.
- Mientras tanto se ve un **círculo de carga**; luego se muestra `CameraPreview`.

**Para la exposición al grupo:**
> Sacamos la lista de cámaras, elegimos la trasera, creamos el controlador y lo inicializamos con `await controller.initialize()`. Mientras se inicializa, se muestra un indicador de carga.

---

## Punto 3 — Lectura de la cámara (capturar la foto)

```dart
final photo = await controller.takePicture();   // lee la imagen de la cámara
```

- Con solo presionar el botón círculo para tomar foto, `takePicture()` **lee la imagen** del sensor.
- Nos la devuelve como un `XFile`.
- Es asíncrono, así que manejamos el error con `try/catch` y bloqueamos el toque doble con una bandera `_isTakingPhoto`.

**Para la exposición al grupo:**
> Al presionar el botón, `takePicture()` lee la imagen capturada del sensor de la cámara y nos la entrega en un `XFile`.

---

## Punto 4 — Almacenamiento de la imagen

```dart
final dir = await getApplicationDocumentsDirectory();        // 1. carpeta de la app
final fileName = 'foto_${DateTime.now().millisecondsSinceEpoch}.jpg'; // 2. nombre único
final file = File(p.join(dir.path, fileName));               // 3. ruta completa
await photo.saveTo(file.path);                               // 4. guarda la foto
return file.path;                                            // 5. devuelve la ruta
```

- Guardar en la **carpeta privada** de la app (su pantalla, no la galería).
- El nombre usa la **fecha/hora actual** para que nunca se repita.
- `p.join` une carpeta + nombre.
- `photo.saveTo(...)` copia la imagen al disco.
- Regresamos y guardamos solo la **ruta**, no la imagen entera.

**Para la exposición al grupo:**
> La foto se copia a la carpeta privada de la app con un nombre único por fecha, y devolvemos su ruta. La imagen en sí no se guarda en la base de datos.

---

## Punto 5 — Almacenamiento en la base de datos

```dart
Future<int> insertMember(Member member) async {
  final db = await database;                // 1. abrir/crear la BD
  final map = member.toMap()..remove('id'); // 2. convertir el objeto a Mapa
  return db.insert(_table, map);            // 3. insertar en la tabla 'miembros'
}
```

- La primera vez, la BD crea sola el archivo y la tabla `miembros` (`CREATE TABLE`).
- `toMap()` convierte el objeto `Member` en un objeto clave/valor.
- Se quita `id` porque la BD lo genera sola (autoincrement).
- `db.insert` equivale a un `INSERT INTO` y guarda todo.
- Ojo: aquí solo se guarda la **ruta** de la foto, no la imagen.

**Para la exposición al grupo:**
> El objeto `Member` se convierte en un mapa con `toMap()` y se inserta en SQLite con `db.insert`. La base de datos se crea sola. De la foto solo se guarda la ruta.

---

## Punto 6 — Consulta de la base de datos

Código en `lib/data/database_helper.dart`:

**a) Traer todos los miembros (pantalla Reporte):**
```dart
final maps = await db.query(_table, orderBy: 'nombre ASC'); // SELECT * ORDER BY nombre
return maps.map(Member.fromMap).toList();                   // cada fila → objeto Member
```

**b) Buscar por nombre (pantalla Buscar):**
```dart
final maps = await db.query(
  _table,
  where: 'nombre LIKE ? OR apellidos LIKE ? OR (nombre || \' \' || apellidos) LIKE ?',
  whereArgs: ['%$query%', '%$query%', '%$query%'],
  orderBy: 'nombre ASC',
);
return maps.map(Member.fromMap).toList();
```

- `db.query()` equivale a un **SELECT**.
- Con `where` filtramos y con `orderBy` ordenamos.
- El `LIKE ?` con `%` busca **coincidencias parciales** (no exactas) en nombre o apellido. `whereArgs` rellena los `?` de forma segura.
- `db.query` devuelve una lista de mapas (filas); `Member.fromMap` convierte cada fila en un objeto `Member`.

**Para la exposición al grupo:**
> Hacemos consultas tipo SELECT con `db.query()`. Para el reporte traemos todos, y para la búsqueda usamos `LIKE` con `%` alrededor del texto para encontrar coincidencias por nombre o apellido. Cada fila se convierte de mapa a objeto `Member` con `fromMap`.

---

*Punto 7 (lectura y presentación de la imagen) lo agregamos a continuación.*

## Punto 7 — Lectura y presentación de la imagen

Código en `lib/widgets/member_card.dart` (y `lib/widgets/photo_picker_widget.dart`):

```dart
CircleAvatar(
  backgroundImage: member.fotoPath != null
      ? FileImage(File(member.fotoPath!))   // lee la imagen del archivo en disco
      : null,                                // si no hay foto, icono por defecto
)
```

- En puntos anteriores guardamos solo la **ruta** (`fotoPath`) en la base de datos.
- `File(ruta)` abre el archivo de disco **a partir de esa ruta**.
- `FileImage(...)` convierte ese archivo en una imagen que Flutter puede dibujar.
- `CircleAvatar` (avatar circular) la muestra. Si el campo es `null` (no hay foto), no carga imagen y aparece un icono de persona.
- En el formulario (registrar/editar) se usa igual con `PhotoPickerWidget`.

**Para la exposición al grupo:**
> Solo guardamos la ruta de la foto en la base de datos. Para mostrarla, creamos un `File` con esa ruta y la pasamos con `FileImage`. Ese archivo se dibuja en un círculo (avatar); si no hay foto, se muestra un icono por defecto.

---

*¡Listo! Los 7 puntos del profesor están cubiertos en este documento.*