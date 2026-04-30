import 'package:latlong2/latlong.dart';

class AppConstants {
  static const LatLng lotaCenter = LatLng(-37.0896, -73.1584);
  static const double lotaDefaultZoom = 14.0;
  static const double lotaDetailZoom = 17.0;

  static const String mapTileUrl = 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png';
  static const List<String> mapSubdomains = ['a', 'b', 'c', 'd'];
}
