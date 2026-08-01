import 'dart:io';

import 'package:camera/camera.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class CameraService {
  CameraService._();

  static Future<String> savePhoto(XFile photo) async {
    final dir = await getApplicationDocumentsDirectory();
    final fileName = 'foto_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final file = File(p.join(dir.path, fileName));
    await photo.saveTo(file.path);
    return file.path;
  }
}
