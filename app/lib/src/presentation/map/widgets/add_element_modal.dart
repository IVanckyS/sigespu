import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';
import '../../../config/constants.dart';
import '../../../config/map_config.dart';
import '../../../config/theme.dart';
import '../../../data/seed_data.dart';
import '../../../presentation/auth/auth_provider.dart';
import '../layers/custom_markers.dart';
import '../providers/map_providers.dart';
import 'location_picker.dart';

class AddElementModal extends ConsumerStatefulWidget {
  const AddElementModal({super.key});

  @override
  ConsumerState<AddElementModal> createState() => _AddElementModalState();
}

class _AddElementModalState extends ConsumerState<AddElementModal> {
  String? _selectedType;
  double _lat = AppConstants.lotaCenter.latitude;
  double _lng = AppConstants.lotaCenter.longitude;
  bool _gpsLoading = true;

  final _nombreCtrl = TextEditingController();
  final _direccionCtrl = TextEditingController();
  final _notasCtrl = TextEditingController();
  final _capacidadCtrl = TextEditingController();
  final _rutCtrl = TextEditingController();
  final _giroCtrl = TextEditingController();
  int _nivel = 3;
  String _tipoPeligro = 'robos';
  String _horario = '24/7';

  final _formKey = GlobalKey<FormState>();

  static const _tiposPeligro = MapLayerConfig.tiposPeligro;
  static const _horarios = MapLayerConfig.horarios;
  static const _grupos = MapLayerConfig.elementGroups;

  @override
  void initState() {
    super.initState();
    _captureGPS();
  }

  Future<void> _captureGPS() async {
    try {
      final perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      ).timeout(const Duration(seconds: 5));
      if (mounted) {
        setState(() {
          _lat = pos.latitude;
          _lng = pos.longitude;
          _gpsLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _gpsLoading = false);
    }
  }

  Future<void> _pickOnMap() async {
    final result = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(
        builder: (context) => PickLocationPage(
          initialLocation: LatLng(_lat, _lng),
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _lat = result.latitude;
        _lng = result.longitude;
      });
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _direccionCtrl.dispose();
    _notasCtrl.dispose();
    _capacidadCtrl.dispose();
    _rutCtrl.dispose();
    _giroCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: _selectedType == null ? _buildTypeGrid() : _buildForm(),
    );
  }

  // ── Grilla de selección de tipo ────────────────────────────────────────────

  Widget _buildTypeGrid() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.stone300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Agregar elemento',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.stone900,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Selecciona el tipo. El GPS capturará tu ubicación.',
            style: TextStyle(fontSize: 12.5, color: AppTheme.stone500),
          ),
          const SizedBox(height: 16),
          ..._grupos.map((grupo) {
            final (titulo, tipos) = grupo;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.stone500,
                    letterSpacing: 0.06,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: tipos.map((tipo) {
                    final color = CustomMarkers.getColorForTipo(tipo);
                    final icon = CustomMarkers.getIconForTipo(tipo);
                    final nombre = _nombreParaTipoExtended(tipo);
                    return GestureDetector(
                      onTap: () => setState(() => _selectedType = tipo),
                      child: Container(
                        width: 90,
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.stone50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.stone200),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(icon, color: color, size: 20),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              nombre,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.stone800,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],
            );
          }),
        ],
      ),
    );
  }

  // ── Formulario dinámico ────────────────────────────────────────────────────

  Widget _buildForm() {
    final tipo = _selectedType!;
    final color = CustomMarkers.getColorForTipo(tipo);
    final icon = CustomMarkers.getIconForTipo(tipo);
    final nombre = _nombreParaTipoExtended(tipo);

    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.stone300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Header con back + tipo
            Row(
              children: [
                GestureDetector(
                  onTap: () => setState(() => _selectedType = null),
                  child: const Icon(
                    Icons.arrow_back,
                    size: 20,
                    color: AppTheme.stone600,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 16),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Nuevo: $nombre',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.stone900,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Ubicación GPS
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.stone50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.stone200),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_pin,
                    color: AppTheme.orange600,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'UBICACIÓN CAPTURADA',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.stone500,
                            letterSpacing: 0.04,
                          ),
                        ),
                        const SizedBox(height: 2),
                        _gpsLoading
                            ? const Text(
                                'Obteniendo ubicación…',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.stone500,
                                ),
                              )
                            : Text(
                                '${_lat.toStringAsFixed(5)}, ${_lng.toStringAsFixed(5)}',
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.stone800,
                                ),
                              ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _gpsLoading ? null : _pickOnMap,
                    icon: const Icon(Icons.map_outlined, size: 16),
                    label: const Text('Cambiar', style: TextStyle(fontSize: 12)),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.orange600,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Nombre / Descripción
            TextFormField(
              controller: _nombreCtrl,
              decoration: InputDecoration(
                labelText: 'Nombre / Descripción *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                isDense: true,
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Requerido' : null,
            ),
            const SizedBox(height: 10),

            // Dirección
            TextFormField(
              controller: _direccionCtrl,
              decoration: InputDecoration(
                labelText: 'Dirección *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                isDense: true,
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Requerido' : null,
            ),
            const SizedBox(height: 10),

            // Campos específicos: zona_peligro
            if (tipo == 'zona_peligro') ...[
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      // ignore: deprecated_member_use
                      value: _tipoPeligro,
                      decoration: InputDecoration(
                        labelText: 'Tipo de peligro',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        isDense: true,
                      ),
                      items: _tiposPeligro
                          .map(
                            (t) => DropdownMenuItem(
                              value: t.$1,
                              child: Text(
                                t.$2,
                                style: const TextStyle(fontSize: 12.5),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _tipoPeligro = v);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      // ignore: deprecated_member_use
                      value: _horario,
                      decoration: InputDecoration(
                        labelText: 'Horario crítico',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        isDense: true,
                      ),
                      items: _horarios
                          .map(
                            (h) => DropdownMenuItem(
                              value: h,
                              child: Text(
                                h,
                                style: const TextStyle(fontSize: 12.5),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _horario = v);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'Nivel de riesgo',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.stone600,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: List.generate(5, (i) {
                  final n = i + 1;
                  final active = _nivel == n;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _nivel = n),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 120),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: active ? AppTheme.redDanger : AppTheme.stone100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: active
                                ? AppTheme.redDanger
                                : AppTheme.stone200,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '$n',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: active ? Colors.white : AppTheme.stone600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 10),
            ],

            // Campos específicos: centro_acopio
            if (tipo == 'centro_acopio') ...[
              TextFormField(
                controller: _capacidadCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Capacidad (personas)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 10),
            ],

            // Campos específicos: patente
            if (tipo == 'patente') ...[
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _rutCtrl,
                      decoration: InputDecoration(
                        labelText: 'RUT',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _giroCtrl,
                      decoration: InputDecoration(
                        labelText: 'Giro comercial',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],

            // Notas
            TextFormField(
              controller: _notasCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Notas / Observaciones',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                isDense: true,
              ),
            ),
            const SizedBox(height: 20),

            // Botones
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.orange600,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Guardar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Guardar elemento ───────────────────────────────────────────────────────

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = ref.read(authProvider);
    final tipo = _selectedType!;

    final nuevo = ElementoMapa(
      id: const Uuid().v4(),
      tipo: tipo,
      nombre: _nombreCtrl.text.trim(),
      direccion: _direccionCtrl.text.trim(),
      sector: 'Centro',
      lat: _lat,
      lng: _lng,
      estado: 'activo',
      fecha: DateTime.now().toIso8601String().substring(0, 10),
      by: auth.user?['nombre'] as String? ?? 'Funcionario',
      notas: _notasCtrl.text.trim(),
      nivel: tipo == 'zona_peligro' ? _nivel : null,
      tipoPeligro: tipo == 'zona_peligro' ? _tipoPeligro : null,
      horario: tipo == 'zona_peligro' ? _horario : null,
      capacidad: tipo == 'centro_acopio' && _capacidadCtrl.text.isNotEmpty
          ? int.tryParse(_capacidadCtrl.text)
          : null,
      rut: tipo == 'patente' && _rutCtrl.text.isNotEmpty
          ? _rutCtrl.text.trim()
          : null,
      giro: tipo == 'patente' && _giroCtrl.text.isNotEmpty
          ? _giroCtrl.text.trim()
          : null,
    );

    ref.read(userElementsProvider.notifier).update((s) => [...s, nuevo]);
    ref.read(activeLayersProvider.notifier).enable(nuevo.tipo);

    // POST directo al backend (sin pasar por la cola Drift)
    bool sincronizado = false;
    try {
      final storage = ref.read(secureStorageProvider);
      final token = await storage.read(key: 'access_token');
      final resp = await http.post(
        Uri.parse('${AppConstants.apiBaseUrl}/api/elementos'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'id': nuevo.id,
          'tipo': nuevo.tipo,
          'nombre': nuevo.nombre,
          'direccion': nuevo.direccion,
          'lat': nuevo.lat,
          'lng': nuevo.lng,
          'estado': nuevo.estado,
          'descripcion': nuevo.notas,
          'metadata': {
            'capacidad': nuevo.capacidad,
            'rut': nuevo.rut,
            'giro': nuevo.giro,
            'tipoPeligro': nuevo.tipoPeligro,
            'nivel': nuevo.nivel,
            'horario': nuevo.horario,
            'sector': nuevo.sector,
          },
        }),
      ).timeout(const Duration(seconds: 8));
      sincronizado = resp.statusCode == 200 || resp.statusCode == 201;
    } catch (_) {
      sincronizado = false;
    }

    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(sincronizado
            ? '${_nombreParaTipoExtended(nuevo.tipo)} guardado en base de datos'
            : '${_nombreParaTipoExtended(nuevo.tipo)} guardado localmente'),
        backgroundColor: sincronizado ? AppTheme.greenSuccess : AppTheme.amberWarning,
      ),
    );
  }

  // ── Helper: nombre para tipo (extiende seed_data con camara_cctv) ──────────

  String _nombreParaTipoExtended(String tipo) {
    if (tipo == 'camara_cctv') return 'Cámara CCTV';
    return nombreParaTipo(tipo);
  }
}
