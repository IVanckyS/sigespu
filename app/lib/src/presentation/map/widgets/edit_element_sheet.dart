import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../../config/map_config.dart';
import '../../../config/theme.dart';
import '../../../data/seed_data.dart';
import '../providers/map_providers.dart';
import 'location_picker.dart';
import '../../../data/sync/sync_provider.dart';

class EditElementSheet extends ConsumerStatefulWidget {
  final ElementoMapa elemento;

  const EditElementSheet({super.key, required this.elemento});

  @override
  ConsumerState<EditElementSheet> createState() => _EditElementSheetState();
}

class _EditElementSheetState extends ConsumerState<EditElementSheet> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nombreCtrl;
  late TextEditingController _direccionCtrl;
  late TextEditingController _notasCtrl;
  
  // Fields for specific types
  late TextEditingController _capacidadCtrl;
  late TextEditingController _rutCtrl;
  late TextEditingController _giroCtrl;
  
  late double _lat;
  late double _lng;
  late String _estado;
  late int _nivel;
  late String _tipoPeligro;
  late String _horario;

  @override
  void initState() {
    super.initState();
    _nombreCtrl = TextEditingController(text: widget.elemento.nombre);
    _direccionCtrl = TextEditingController(text: widget.elemento.direccion);
    _notasCtrl = TextEditingController(text: widget.elemento.notas);
    
    _capacidadCtrl = TextEditingController(text: widget.elemento.capacidad?.toString() ?? '');
    _rutCtrl = TextEditingController(text: widget.elemento.rut ?? '');
    _giroCtrl = TextEditingController(text: widget.elemento.giro ?? '');
    
    _lat = widget.elemento.lat;
    _lng = widget.elemento.lng;
    _estado = widget.elemento.estado;
    _nivel = widget.elemento.nivel ?? 3;
    _tipoPeligro = widget.elemento.tipoPeligro ?? 'robos';
    _horario = widget.elemento.horario ?? '24/7';
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

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final updated = widget.elemento.copyWith(
      nombre: _nombreCtrl.text.trim(),
      direccion: _direccionCtrl.text.trim(),
      lat: _lat,
      lng: _lng,
      notas: _notasCtrl.text.trim(),
      estado: _estado,
      nivel: widget.elemento.tipo == 'zona_peligro' ? _nivel : null,
      tipoPeligro: widget.elemento.tipo == 'zona_peligro' ? _tipoPeligro : null,
      horario: widget.elemento.tipo == 'zona_peligro' ? _horario : null,
      capacidad: widget.elemento.tipo == 'centro_acopio' ? int.tryParse(_capacidadCtrl.text) : null,
      rut: widget.elemento.tipo == 'patente' ? _rutCtrl.text.trim() : null,
      giro: widget.elemento.tipo == 'patente' ? _giroCtrl.text.trim() : null,
    );

    // Update in provider
    ref.read(userElementsProvider.notifier).update((list) {
      if (list.any((e) => e.id == updated.id)) {
        // Ya era un elemento del usuario
        return list.map((e) => e.id == updated.id ? updated : e).toList();
      } else {
        // Era un elemento de seed, lo promovemos a la lista del usuario
        return [...list, updated];
      }
    });

    // If it's a zone, also update the polygon reference
    if (widget.elemento.tipo == 'zona_peligro') {
      ref.read(userPolygonsProvider.notifier).update((list) {
        return list.map((p) => p.zona.id == updated.id 
          ? (points: p.points, zona: updated) 
          : p).toList();
      });
    }

    // Encolar para sync con el backend
    ref.read(syncServiceProvider).queueForSync(
      entidad: 'punto_interes',
      accion: 'update',
      entidadId: updated.id,
      payload: {
        'id': updated.id,
        'tipo': updated.tipo,
        'nombre': updated.nombre,
        'direccion': updated.direccion,
        'lat': updated.lat,
        'lng': updated.lng,
        'estado': updated.estado,
        'descripcion': updated.notas,
        'metadata': {
          'capacidad': updated.capacidad,
          'rut': updated.rut,
          'giro': updated.giro,
          'tipoPeligro': updated.tipoPeligro,
          'nivel': updated.nivel,
          'horario': updated.horario,
        }
      },
    );

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Elemento actualizado correctamente'),
        backgroundColor: AppTheme.greenSuccess,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tipoLabel = nombreParaTipo(widget.elemento.tipo);
    final cat = categoriaParaTipo(widget.elemento.tipo);
    final isBinary = cat == 'infraestructura' || cat == 'fiscalizacion';

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 20, left: 20, right: 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(_getIcon(), color: colorParaTipo(widget.elemento.tipo)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Editar $tipoLabel',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 16),
              
              // Location Picker
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.location_on, color: AppTheme.redDanger),
                title: const Text('Ubicación'),
                subtitle: Text('${_lat.toStringAsFixed(6)}, ${_lng.toStringAsFixed(6)}'),
                trailing: TextButton(
                  onPressed: () async {
                    final result = await Navigator.push<LatLng>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PickLocationPage(initialLocation: LatLng(_lat, _lng)),
                      ),
                    );
                    if (result != null) {
                      setState(() {
                        _lat = result.latitude;
                        _lng = result.longitude;
                      });
                    }
                  },
                  child: const Text('Cambiar'),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _nombreCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nombre / Identificador',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _direccionCtrl,
                decoration: const InputDecoration(
                  labelText: 'Dirección',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                // ignore: deprecated_member_use
                value: _estado == 'vigente' ? 'activo' : (_estado == 'vencido' ? 'cerrado' : _estado),
                decoration: const InputDecoration(
                  labelText: 'Estado',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(value: 'activo', child: Text('Activo')),
                  if (!isBinary)
                    const DropdownMenuItem(value: 'en_revision', child: Text('En revisión')),
                  DropdownMenuItem(value: 'cerrado', child: Text(isBinary ? 'Inactivo' : 'Cerrado')),
                ],
                onChanged: (v) => setState(() => _estado = v!),
              ),
              const SizedBox(height: 16),

              // Type specific fields
              if (widget.elemento.tipo == 'zona_peligro') ...[
                DropdownButtonFormField<String>(
                  // ignore: deprecated_member_use
                  value: _tipoPeligro,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de Peligro',
                    border: OutlineInputBorder(),
                  ),
                  items: MapLayerConfig.tiposPeligro.map((t) => DropdownMenuItem(
                    value: t.$1,
                    child: Text(t.$2),
                  )).toList(),
                  onChanged: (v) => setState(() => _tipoPeligro = v!),
                ),
                const SizedBox(height: 16),
                const Text('Nivel de Riesgo (1-5):', style: TextStyle(fontWeight: FontWeight.bold)),
                Slider(
                  value: _nivel.toDouble(),
                  min: 1,
                  max: 5,
                  divisions: 4,
                  label: _nivel.toString(),
                  onChanged: (v) => setState(() => _nivel = v.round()),
                ),
                DropdownButtonFormField<String>(
                  // ignore: deprecated_member_use
                  value: _horario,
                  decoration: const InputDecoration(
                    labelText: 'Horario crítico',
                    border: OutlineInputBorder(),
                  ),
                  items: MapLayerConfig.horarios.map((h) => DropdownMenuItem(
                    value: h,
                    child: Text(h),
                  )).toList(),
                  onChanged: (v) => setState(() => _horario = v!),
                ),
                const SizedBox(height: 16),
              ],

              if (widget.elemento.tipo == 'centro_acopio') ...[
                TextFormField(
                  controller: _capacidadCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Capacidad estimada (personas)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
              ],

              if (widget.elemento.tipo == 'patente') ...[
                TextFormField(
                  controller: _rutCtrl,
                  decoration: const InputDecoration(
                    labelText: 'RUT Comercial',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _giroCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Giro / Actividad',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              TextFormField(
                controller: _notasCtrl,
                decoration: const InputDecoration(
                  labelText: 'Notas adicionales',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.orange600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('GUARDAR CAMBIOS', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIcon() {
    switch (widget.elemento.tipo) {
      case 'zona_peligro': return Icons.warning;
      case 'centro_acopio': return Icons.home_work;
      case 'patente': return Icons.store;
      case 'camara_cctv': return Icons.videocam;
      case 'grifo': return Icons.water_drop;
      default: return Icons.place;
    }
  }
}
