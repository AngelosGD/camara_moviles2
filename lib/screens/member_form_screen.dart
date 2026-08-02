import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/member.dart';
import '../providers/member_provider.dart';
import '../services/camera_service.dart';
import '../widgets/photo_picker_widget.dart';
import 'camera_screen.dart';

class MemberFormScreen extends StatefulWidget {
  final Member? member;

  const MemberFormScreen({super.key, this.member});

  bool get isEditing => member != null;

  @override
  State<MemberFormScreen> createState() => _MemberFormScreenState();
}

class _MemberFormScreenState extends State<MemberFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreController;
  late final TextEditingController _apellidosController;
  final _telefonoController = TextEditingController();
  final _emailController = TextEditingController();
  String? _fotoPath;
  bool _isSaving = false;

  bool get _isEditing => widget.isEditing;

  @override
  void initState() {
    super.initState();
    final m = widget.member;
    _nombreController = TextEditingController(text: m?.nombre ?? '');
    _apellidosController = TextEditingController(text: m?.apellidos ?? '');
    _telefonoController.text = m?.telefono ?? '';
    _emailController.text = m?.email ?? '';
    _fotoPath = m?.fotoPath;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidosController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _onTakePhoto() async {
    final path = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const CameraScreen()),
    );
    if (path != null && mounted) {
      setState(() => _fotoPath = path);
    }
  }

  Future<void> _onPickFromGallery() async {
    final photo = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (photo == null || !mounted) return;
    try {
      final path = await CameraService.savePhoto(photo);
      if (!mounted) return;
      setState(() => _fotoPath = path);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo cargar la imagen')),
      );
    }
  }

  Future<void> _onSave() async {
    if (_isSaving || !_formKey.currentState!.validate()) return;

    final provider = context.read<MemberProvider>();

    if (_isEditing) {
      final updated = Member(
        id: widget.member!.id,
        nombre: _nombreController.text.trim(),
        apellidos: _apellidosController.text.trim(),
        telefono: _telefonoController.text.trim().isEmpty
            ? null
            : _telefonoController.text.trim(),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        fotoPath: _fotoPath,
        fechaRegistro: widget.member!.fechaRegistro,
      );
      try {
        setState(() => _isSaving = true);
        await provider.updateMember(updated);
        if (!mounted) return;
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Miembro actualizado correctamente')),
        );
      } catch (_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al actualizar el miembro')),
        );
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
      return;
    }

    final member = Member(
      nombre: _nombreController.text.trim(),
      apellidos: _apellidosController.text.trim(),
      telefono: _telefonoController.text.trim().isEmpty
          ? null
          : _telefonoController.text.trim(),
      email: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      fotoPath: _fotoPath,
    );

    setState(() => _isSaving = true);
    try {
      await provider.registerMember(member);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Miembro registrado correctamente')),
      );
      _formKey.currentState!.reset();
      _nombreController.clear();
      _apellidosController.clear();
      _telefonoController.clear();
      _emailController.clear();
      setState(() => _fotoPath = null);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al registrar el miembro')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Miembro' : 'Registrar Miembro'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              PhotoPickerWidget(
                imagePath: _fotoPath,
                onTakePhoto: _onTakePhoto,
                onPickFromGallery: _onPickFromGallery,
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre *'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _apellidosController,
                decoration: const InputDecoration(labelText: 'Apellidos *'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _telefonoController,
                decoration: const InputDecoration(labelText: 'Teléfono'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _onSave,
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_isEditing
                          ? 'ACTUALIZAR MIEMBRO'
                          : 'GUARDAR MIEMBRO'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}