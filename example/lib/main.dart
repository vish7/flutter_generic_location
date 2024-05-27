import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_generic_location/flutter_generic_location.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _flutterGenericLocationPlugin = FlutterGenericLocation();
  late StreamSubscription<Map<String, dynamic>> streamSubscription;
  bool runningLocationUpdates = false;
  bool runningLocationService = false;

  Map<String, dynamic> _location = {};
  String _error = "";

  @override
  void initState() {
    super.initState();
    streamSubscription = FlutterGenericLocation.locationStream.listen((location) {
      setState(() {
        _location = location;
      });
    });
  }

  Future<void> getLocaion() async {
    try {
      final location = await _flutterGenericLocationPlugin.getLocation();
      setState(() {
        _location = location;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  Future<void> getLastLocation() async {
    try {
      final location = await _flutterGenericLocationPlugin.getLastLocation();
      setState(() {
        _location = location;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  Future<void> startStopLocationUpdates() async {
    try {
      if (runningLocationUpdates == false) {
        await _flutterGenericLocationPlugin.startLocationUpdates();
        runningLocationUpdates = true;
      } else {
        _flutterGenericLocationPlugin.stopLocationUpdates();
        runningLocationUpdates = false;
      }
      setState(() {});
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  Future<void> startAndStopLocaitonService() async {
    try {
      if (runningLocationService == false) {
        await _flutterGenericLocationPlugin.startLocationService();
        runningLocationService = true;
      } else {
        _flutterGenericLocationPlugin.stopLocationService();
        runningLocationService = false;
      }
      setState(() {});
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  Future<Uint8List> fetchNotificationIcon() async {
    ByteData imageData = await rootBundle.load('assets/images/notificaiton_icon.png');
    return imageData.buffer.asUint8List();
  }

  Future<void> showNotification() async {
    try {
      final notificationIcon = await fetchNotificationIcon();
      await _flutterGenericLocationPlugin.showNotification(
          'Test Notification', 'This is a test notification message', "PluginDemoChannel", notificationIcon);
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Generic Location Demo'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Location Info on: $_location\n',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'Error: $_error\n',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => getLocaion(),
                  child: const Text("Fetch Locaiton"),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => getLastLocation(),
                  child: const Text("Fetch Last Locaiton"),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => startStopLocationUpdates(),
                  child: runningLocationUpdates
                      ? const Text("Stop Location Updates")
                      : const Text("Start Location Updates"),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => showNotification(),
                  child: const Text("Show Notification"),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => startAndStopLocaitonService(),
                  child: runningLocationService
                      ? const Text("Stop Location Service")
                      : const Text("Start Location Service"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
