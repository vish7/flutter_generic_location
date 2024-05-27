import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'flutter_generic_location_method_channel.dart';
import 'dart:typed_data';

abstract class FlutterGenericLocationPlatform extends PlatformInterface {
  /// Constructs a FlutterGenericLocationPlatform.
  FlutterGenericLocationPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterGenericLocationPlatform _instance = MethodChannelFlutterGenericLocation();

  /// The default instance of [FlutterGenericLocationPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterGenericLocation].
  static FlutterGenericLocationPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterGenericLocationPlatform] when
  /// they register themselves.
  static set instance(FlutterGenericLocationPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<Map<String, dynamic>> getLocation() {
    throw UnimplementedError('getLocation() has not been implemented.');
  }

  Future<Map<String, dynamic>> getLastLocation() {
    throw UnimplementedError('getLastLocation() has not been implemented.');
  }

  Future<Map<String, dynamic>> startLocationUpdates() {
    throw UnimplementedError('startLocationUpdates() has not been implemented.');
  }

  Future<Map<String, dynamic>> stopLocationUpdates() {
    throw UnimplementedError('stopLocationUpdates() has not been implemented.');
  }

  Stream<Map<String, dynamic>> getLocationStream() {
    throw UnimplementedError('getLocationStream() has not been implemented.');
  }

  Future<Map<String, dynamic>> startLocationService() {
    throw UnimplementedError('startLocationService() has not been implemented.');
  }

  Future<Map<String, dynamic>> stopLocationService() {
    throw UnimplementedError('stopLocationService() has not been implemented.');
  }

  Future<Map<String, dynamic>> showNotification(String title, String message, String channelId, Uint8List imageBytes) {
    throw UnimplementedError('showNotification() has not been implemented.');
  }
}
