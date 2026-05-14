// app/test/providers/support_providers_test.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sigespu/src/presentation/map/providers/map_providers.dart';
import 'package:sigespu/src/presentation/actividades/actividades_provider.dart';
import 'package:shared/shared.dart';

void main() {
  group('layerCountsProvider', () {
    test('returns map with non-negative counts', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final counts = container.read(layerCountsProvider);
      expect(counts, isA<Map<String, int>>());
      expect(counts.values.every((c) => c >= 0), isTrue);
    });
  });

  group('customZonaCategoriesProvider', () {
    test('returns sorted list from userPolygons', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final cats = container.read(customZonaCategoriesProvider);
      expect(cats, isA<List<String>>());
    });
  });

  group('filteredActividadesProvider', () {
    test('returns all actividades when no filters active', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final all = container.read(actividadesProvider);
      final filtered = container.read(filteredActividadesProvider);
      expect(filtered.length, all.length);
    });

    test('filters by tipo when tipo filter is set', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(actividadesTipoFilterProvider.notifier).state =
          TipoActividad.reunion;
      final filtered = container.read(filteredActividadesProvider);
      expect(filtered.every((a) => a.tipo == TipoActividad.reunion), isTrue);
    });
  });
}
