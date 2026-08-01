import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../services/camera_service.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  List<CameraDescription> _cameras = <CameraDescription>[];
  bool _isInitializing = true;
  bool _isTakingPhoto = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        _showError('No se encontró una cámara disponible');
        return;
      }
      _cameras = cameras;
      final initial = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        initial,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _isInitializing = false;
      });
    } catch (_) {
      _showError('Error al inicializar la cámara');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    setState(() {
      _error = message;
      _isInitializing = false;
    });
  }

  Future<void> _switchCamera() async {
    final controller = _controller;
    if (controller == null || _isInitializing || _cameras.length < 2) return;

    final next = _cameras.firstWhere(
      (c) => c.lensDirection != controller.description.lensDirection,
      orElse: () => controller.description,
    );
    if (identical(next, controller.description)) return;

    setState(() => _isInitializing = true);
    try {
      await controller.setDescription(next);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo cambiar de cámara')),
      );
    } finally {
      if (mounted) setState(() => _isInitializing = false);
    }
  }

  Future<void> _takePicture() async {
    final controller = _controller;
    if (controller == null ||
        !controller.value.isInitialized ||
        _isTakingPhoto) {
      return;
    }

    setState(() => _isTakingPhoto = true);
    try {
      final photo = await controller.takePicture();
      final path = await CameraService.savePhoto(photo);
      if (!mounted) return;
      Navigator.of(context).pop(path);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo tomar la foto')),
      );
    } finally {
      if (mounted) setState(() => _isTakingPhoto = false);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Tomar Foto'),
      ),
      body: _buildBody(),
      bottomNavigationBar: _isInitializing || _error != null
          ? null
          : _buildShutterBar(),
    );
  }

  Widget _buildBody() {
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.no_photography_outlined,
                  size: 64, color: Colors.white54),
              const SizedBox(height: 16),
              Text(
                _error!,
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (_isInitializing) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return _buildPreview();
  }

  Widget _buildPreview() {
    final controller = _controller!;
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = 1 /
            (controller.value.aspectRatio *
                constraints.maxWidth /
                constraints.maxHeight);
        return ClipRect(
          child: Transform.scale(
            scale: scale,
            alignment: Alignment.center,
            child: CameraPreview(controller),
          ),
        );
      },
    );
  }

  Widget _buildShutterBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              tooltip: 'Cambiar de cámara',
              iconSize: 32,
              color: Colors.white,
              onPressed: _cameras.length > 1 ? _switchCamera : null,
              icon: const Icon(Icons.cameraswitch),
            ),
            GestureDetector(
              onTap: _takePicture,
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: Colors.black38, width: 4),
                ),
                child: _isTakingPhoto
                    ? const Padding(
                        padding: EdgeInsets.all(22),
                        child: CircularProgressIndicator(strokeWidth: 3),
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 48),
          ],
        ),
      ),
    );
  }
}
