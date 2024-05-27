# flutter_generic_location

A Flutter plugin for fetching location in the foreground and background on Android and iOS.

## Platform

- [x] Android
- [x] iOS

## Features

* Can request location permission.
* Can get the current location of the device.
* Can subscribe to `LocationStream` to collect location data in real time.

## Getting started

To use this plugin, add `flutter_generic_location` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/). For example:

```yaml
dependencies:
  flutter_generic_location: ^0.0.1
```

After adding the `flutter_generic_location` plugin to the flutter project, we need to specify the platform-specific permissions for this plugin to work properly.

### :baby_chick: Android

Since this plugin works based on location, we need to add the following permission to the `AndroidManifest.xml` file. Open the `AndroidManifest.xml` file and specify it between the `<manifest>` and `<application>` tags.

```
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

If you want to get the location in the background, add the following permission. If your project supports Android 10, be sure to add the `ACCESS_BACKGROUND_LOCATION` permission.

```
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
```

### :baby_chick: iOS

Like the Android platform, this plugin works based on location, we need to add the following description. Open the `ios/Runner/Info.plist` file and specify it inside the `<dict>` tag.

```
<key>NSLocationWhenInUseUsageDescription</key>
<string>Used to collect location data.</string>
```

If you want to get the location in the background, add the following description.

```
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Used to collect location data in the background.</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>Used to collect location data in the background.</string>
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>location</string>
</array>
```


## Support

If you find any bugs or issues while using the plugin, please register an issues on [GitHub](https://github.com/vish7/flutter_generic_location/issues).
