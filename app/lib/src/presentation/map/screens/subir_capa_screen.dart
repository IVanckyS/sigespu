import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:http/http.dart' as http;
import '../../../config/constants.dart';
import '../../auth/auth_provider.dart';
import '../providers/visor_provider.dart';

class SubirCapaScreen extends ConsumerStatefulWidget {
  const SubirCapaScreen({super.key});

  @override
  ConsumerState<SubirCapaScreen> createState() => _SubirCapaScreenState();
}

class _SubirCapaScreenState extends ConsumerState<SubirCapaScreen> {
  final _nombreCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _categoria = 'Personalizadas';
  Color _color = const Color(0xFFFF5722);
  PlatformFile? _file;
  bool _uploading = false;
  String? _error;

  final _categorias = [
    'Amenazas',
    'Infraestructura',
    'Seguridad',
    'Municipal',
    'Personalizadas',
  ];

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        decoration: const BoxDecoration(
          color: Color(0xFF1E2327),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Subir capa personalizada',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _field(_nombreCtrl, 'Nombre *'),
            const SizedBox(height: 10),
            _field(_descCtrl, 'Descripción (opcional)'),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _categoria,
              dropdownColor: const Color(0xFF1E2327),
              style: const TextStyle(color: Colors.white, fontSize: 12),
              decoration: _inputDecoration('Categoría'),
              items: _categorias
                  .map((c) => DropdownMenuItem(
                        value: c,
                        child: Text(c),
                      ))
                  .toList(),
              onChanged: (val) => setState(() => _categoria = val!),
            ),
            const SizedBox(height: 12),
            Row(children: [
              const Text('Color:',
                  style: TextStyle(color: Colors.white54, fontSize: 12)),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _pickColor,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _color,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.white24),
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _pickFile,
              icon: const Icon(Icons.attach_file, size: 16),
              label: Text(
                _file == null
                    ? 'Seleccionar archivo (.kmz, .geojson, .zip)'
                    : _file!.name,
                style: const TextStyle(fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white54,
                side: const BorderSide(color: Colors.white24),
              ),
            ),
            if (_file?.extension == 'zip' || _file?.extension == 'shp')
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  'El ZIP debe contener .shp, .dbf y .prj juntos.',
                  style: TextStyle(color: Colors.amber, fontSize: 10),
                ),
              ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _error!,
                  style:
                      const TextStyle(color: Colors.redAccent, fontSize: 12),
                ),
              ),
            const SizedBox(height: 16),
            if (_uploading) const LinearProgressIndicator(),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _uploading ? null : _upload,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00897B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Subir capa'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(color: Colors.white, fontSize: 12),
      decoration: _inputDecoration(label),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white38, fontSize: 11),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white12),
        borderRadius: BorderRadius.circular(6),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFF00897B)),
        borderRadius: BorderRadius.circular(6),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      isDense: true,
    );
  }

  void _pickColor() {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFF1E2327),
        title: const Text(
          'Color de capa',
          style: TextStyle(color: Colors.white, fontSize: 13),
        ),
        content: BlockPicker(
          pickerColor: _color,
          onColorChanged: (c) {
            if (mounted) setState(() => _color = c);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['kmz', 'geojson', 'json', 'zip'],
      withData: true, // Importante para la web y acceso a bytes
    );
    if (result != null) {
      setState(() {
        _file = result.files.first;
        _error = null;
      });
    }
  }

  Future<void> _upload() async {
    if (_nombreCtrl.text.trim().isEmpty) {
      setState(() => _error = 'El nombre es obligatorio');
      return;
    }
    if (_file == null) {
      setState(() => _error = 'Selecciona un archivo');
      return;
    }

    setState(() {
      _uploading = true;
      _error = null;
    });

    try {
      final storage = ref.read(secureStorageProvider);
      final token = await storage.read(key: 'access_token');
      
      final colorHex =
          '#${_color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
      
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${AppConstants.apiBaseUrl}/api/capas/upload'),
      );
      
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      request.fields['nombre'] = _nombreCtrl.text.trim();
      if (_descCtrl.text.trim().isNotEmpty) {
        request.fields['descripcion'] = _descCtrl.text.trim();
      }
      request.fields['color'] = colorHex;
      request.fields['categoria'] = _categoria;

      if (kIsWeb || _file!.bytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'archivo',
            _file!.bytes!,
            filename: _file!.name,
          ),
        );
      } else {
        request.files.add(
          await http.MultipartFile.fromPath('archivo', _file!.path!),
        );
      }

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200 || response.statusCode == 201) {
        ref.invalidate(capasPersonalizadasProvider);
        if (mounted) Navigator.pop(context);
      } else {
        String errorMsg = 'Error al subir (${response.statusCode})';
        try {
          final body = jsonDecode(response.body);
          errorMsg = body['error'] ?? errorMsg;
        } catch (_) {}
        
        if (mounted) {
          setState(() => _error = errorMsg);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'Error de red: $e');
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }
}
