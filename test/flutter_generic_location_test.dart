import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_generic_location/flutter_generic_location.dart';
import 'package:flutter_generic_location/flutter_generic_location_platform_interface.dart';
import 'package:flutter_generic_location/flutter_generic_location_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'dart:typed_data';

class MockFlutterGenericLocationPlatform with MockPlatformInterfaceMixin implements FlutterGenericLocationPlatform {
  @override
  Future<Map<String, dynamic>> getLocation() => Future.value({
        'latitude': '25.454544',
        'longitude': '75.4545454',
      });

  @override
  Stream<Map<String, dynamic>> getLocationStream() => Stream.value({
        'latitude': '25.454544',
        'longitude': '75.4545454',
      });

  @override
  Future<Map<String, dynamic>> getLastLocation() => Future.value({
        'latitude': '25.454544',
        'longitude': '75.4545454',
      });

  @override
  Future<Map<String, dynamic>> startLocationUpdates() => Future.value({
        'latitude': '25.454544',
        'longitude': '75.4545454',
      });

  @override
  Future<Map<String, dynamic>> stopLocationUpdates() => Future.value({
        'latitude': '25.454544',
        'longitude': '75.4545454',
      });

  @override
  Future<Map<String, dynamic>> startLocationService() => Future.value({
        'latitude': '25.454544',
        'longitude': '75.4545454',
      });

  @override
  Future<Map<String, dynamic>> stopLocationService() => Future.value({
        'latitude': '25.454544',
        'longitude': '75.4545454',
      });

  @override
  Future<Map<String, dynamic>> showNotification(String title, String message, String channelId, Uint8List imageBytes) =>
      Future.value({
        'latitude': '25.454544',
        'longitude': '75.4545454',
      });
}

void main() {
  final FlutterGenericLocationPlatform initialPlatform = FlutterGenericLocationPlatform.instance;

  test('$MethodChannelFlutterGenericLocation is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterGenericLocation>());
  });

  test('getLocation', () async {
    FlutterGenericLocation flutterGenericLocationPlugin = FlutterGenericLocation();
    MockFlutterGenericLocationPlatform fakePlatform = MockFlutterGenericLocationPlatform();
    FlutterGenericLocationPlatform.instance = fakePlatform;

    expect(await flutterGenericLocationPlugin.getLocation(), '42');
  });

  test('getLastLocation', () async {
    FlutterGenericLocation flutterGenericLocationPlugin = FlutterGenericLocation();
    MockFlutterGenericLocationPlatform fakePlatform = MockFlutterGenericLocationPlatform();
    FlutterGenericLocationPlatform.instance = fakePlatform;

    expect(await flutterGenericLocationPlugin.getLastLocation(), '42');
  });

  test('startLocationUpdates', () async {
    FlutterGenericLocation flutterGenericLocationPlugin = FlutterGenericLocation();
    MockFlutterGenericLocationPlatform fakePlatform = MockFlutterGenericLocationPlatform();
    FlutterGenericLocationPlatform.instance = fakePlatform;

    expect(await flutterGenericLocationPlugin.startLocationUpdates(), '42');
  });

  test('stopLocationUpdates', () async {
    FlutterGenericLocation flutterGenericLocationPlugin = FlutterGenericLocation();
    MockFlutterGenericLocationPlatform fakePlatform = MockFlutterGenericLocationPlatform();
    FlutterGenericLocationPlatform.instance = fakePlatform;

    expect(await flutterGenericLocationPlugin.stopLocationUpdates(), '42');
  });
}
