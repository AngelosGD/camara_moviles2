class Member {
  final int? id;
  final String nombre;
  final String apellidos;
  final String? telefono;
  final String? email;
  final String? fotoPath;
  final DateTime fechaRegistro;

  Member({
    this.id,
    required this.nombre,
    required this.apellidos,
    this.telefono,
    this.email,
    this.fotoPath,
    DateTime? fechaRegistro,
  }) : fechaRegistro = fechaRegistro ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'id': id,
    'nombre': nombre,
    'apellidos': apellidos,
    'telefono': telefono,
    'email': email,
    'fotoPath': fotoPath,
    'fechaRegistro': fechaRegistro.toIso8601String(),
  };

  factory Member.fromMap(Map<String, dynamic> map) => Member(
    id: map['id'] as int?,
    nombre: map['nombre'] as String,
    apellidos: map['apellidos'] as String,
    telefono: map['telefono'] as String?,
    email: map['email'] as String?,
    fotoPath: map['fotoPath'] as String?,
    fechaRegistro: DateTime.parse(map['fechaRegistro'] as String),
  );
}
