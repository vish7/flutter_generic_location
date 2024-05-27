import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_generic_location_platform_interface.dart';

/// An implementation of [FlutterGenericLocationPlatform] that uses method channels.
class MethodChannelFlutterGenericLocation extends FlutterGenericLocationPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_generic_location');

  final locationEventChannel = const EventChannel('flutter_generic_location_stream');

  @override
  Future<Map<String, dynamic>> getLocation() async {
    try {
      final result = await methodChannel.invokeMethod('getLocation');
      return Map<String, dynamic>.from(result);
    } on PlatformException catch (e) {
      throw 'Failed to get location: ${e.message}';
    }
  }

  @override
  Future<Map<String, dynamic>> getLastLocation() async {
    try {
      final result = await methodChannel.invokeMethod('getLastLocation');
      return Map<String, dynamic>.from(result);
    } on PlatformException catch (e) {
      throw 'Failed to get location: ${e.message}';
    }
  }

  @override
  Future<Map<String, dynamic>> startLocationUpdates() async {
    try {
      final result = await methodChannel.invokeMethod('startLocationUpdates');
      return Map<String, dynamic>.from(result);
    } on PlatformException catch (e) {
      throw 'Failed to get location: ${e.message}';
    }
  }

  @override
  Future<Map<String, dynamic>> stopLocationUpdates() async {
    try {
      final result = await methodChannel.invokeMethod('stopLocationUpdates');
      return Map<String, dynamic>.from(result);
    } on PlatformException catch (e) {
      throw 'Failed to get location: ${e.message}';
    }
  }

  @override
  Future<Map<String, dynamic>> startLocationService() async {
    try {
      final result = await methodChannel.invokeMethod('startLocationService');
      return Map<String, dynamic>.from(result);
    } on PlatformException catch (e) {
      throw 'Failed to get location: ${e.message}';
    }
  }

  @override
  Future<Map<String, dynamic>> stopLocationService() async {
    try {
      final result = await methodChannel.invokeMethod('stopLocationService');
      return Map<String, dynamic>.from(result);
    } on PlatformException catch (e) {
      throw 'Failed to get location: ${e.message}';
    }
  }

  @override
  Stream<Map<String, dynamic>> getLocationStream() {
    try {
      return locationEventChannel.receiveBroadcastStream().map((event) => Map<String, dynamic>.from(event));
    } on PlatformException catch (e) {
      throw 'Failed to get location: ${e.message}';
    }
  }

  @override
  Future<Map<String, dynamic>> showNotification(
      String title, String message, String channelId, Uint8List imageBytes) async {
    try {
      final result = await methodChannel.invokeMethod(
          'showNotification', {'title': title, 'message': message, 'channel_id': channelId, 'image': imageBytes});
      return Map<String, dynamic>.from(result);
    } on PlatformException catch (e) {
      throw 'Failed to get location: ${e.message}';
    }
  }
}
