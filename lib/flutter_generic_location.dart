import 'flutter_generic_location_platform_interface.dart';
import 'dart:typed_data';

class FlutterGenericLocation {
  Future<Map<String, dynamic>> getLocation() {
    return FlutterGenericLocationPlatform.instance.getLocation();
  }

  static Stream<Map<String, dynamic>> get locationStream {
    return FlutterGenericLocationPlatform.instance.getLocationStream();
  }

  Future<Map<String, dynamic>> getLastLocation() {
    return FlutterGenericLocationPlatform.instance.getLastLocation();
  }

  Future<Map<String, dynamic>> startLocationUpdates() {
    return FlutterGenericLocationPlatform.instance.startLocationUpdates();
  }

  Future<Map<String, dynamic>> stopLocationUpdates() {
    return FlutterGenericLocationPlatform.instance.stopLocationUpdates();
  }

  Future<Map<String, dynamic>> startLocationService() {
    return FlutterGenericLocationPlatform.instance.startLocationService();
  }

  Future<Map<String, dynamic>> stopLocationService() {
    return FlutterGenericLocationPlatform.instance.stopLocationService();
  }

  Future<Map<String, dynamic>> showNotification(String title, String message, String channelId, Uint8List imageBytes) {
    return FlutterGenericLocationPlatform.instance.showNotification(title, message, channelId, imageBytes);
  }
}
