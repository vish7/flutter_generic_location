import Flutter
import UIKit
import CoreLocation
import UserNotifications

public class FlutterGenericLocationPlugin: NSObject, FlutterPlugin,FlutterStreamHandler,CLLocationManagerDelegate,UNUserNotificationCenterDelegate {
    
    
    private var locationManager: CLLocationManager?
    private var eventSink: FlutterEventSink?
    private var result: FlutterResult?
    private var method : String?
    private var currentLocation : CLLocation?
    private var sendLocationUpdates : Bool = false
    private var sendLocationService : Bool = false
    private var arguments : Any?
    
    public override init() {
        super.init()
        locationManager = CLLocationManager()
        locationManager?.delegate = self
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_generic_location", binaryMessenger: registrar.messenger())
        let eventChannel = FlutterEventChannel(name: "flutter_generic_location_stream", binaryMessenger: registrar.messenger())
        let instance = FlutterGenericLocationPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        eventChannel.setStreamHandler(instance)
    }
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        self.result = result
        self.method = call.method
        self.arguments = call.arguments
        debugPrint("Method Called",call.method)
        
        if (!hasLocationPermission() && !(call.method == "showNotification")){
            askForLocationPermission()
        }else{
            performActionBasedOnMethod()
        }
    }

    func performActionBasedOnMethod(){
        switch self.method {
        case "getLocation":
          getLocation()
        case "getLastLocation":
            getLastLocation()
        case "startLocationUpdates":
            startLocationUpdates()
        case "stopLocationUpdates":
            stopLocationUpdates()
        case "showNotification":
            checkNotificationPermissions()
        case "startLocationService":
            startLocationService()
        case "stopLocationService":
            stopLocationService()
        default:
            result?(FlutterMethodNotImplemented)
        }
    }

    public func askForLocationPermission() {
        locationManager?.requestWhenInUseAuthorization()
    }

    public func getLocation() {
        debugPrint("getLocation method called");
        locationManager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager?.startUpdatingLocation()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: DispatchWorkItem.init(block: {
            self.locationManager?.stopUpdatingLocation()
            let latitude = self.currentLocation?.coordinate.latitude
            let longitude = self.currentLocation?.coordinate.longitude
            //let locationJson: [String: Any] = ["latitude": latitude, "longitude": longitude]
            let locationData =  "latitude \(latitude ?? -0.0)\n longitude \(longitude ?? -0.0)"
            let locationMap: [String: Any] = [
                "latitude": self.currentLocation?.coordinate.latitude ?? 0.0,
                "longitude": self.currentLocation?.coordinate.longitude ?? 0.0,
                "accuracy": self.currentLocation?.horizontalAccuracy ?? 0,
                "timestamp": (self.currentLocation?.timestamp.timeIntervalSince1970 ?? 0) * 1000
            ]
            self.result?(locationMap)
        }))
    }
    
    public func getLastLocation() {
        debugPrint("getLastLocation method called");
        let latitude = locationManager?.location?.coordinate.latitude
        let longitude = locationManager?.location?.coordinate.longitude
        //let locationJson: [String: Any] = ["latitude": latitude, "longitude": longitude]
        let locationData =  "latitude \(latitude ?? -0.0)\n longitude \(longitude ?? -0.0)"
        let locationMap: [String: Any] = [
            "latitude": locationManager?.location?.coordinate.latitude ?? 0.0,
            "longitude": locationManager?.location?.coordinate.longitude ?? 0.0,
            "accuracy": locationManager?.location?.horizontalAccuracy ?? 0,
            "timestamp": (locationManager?.location?.timestamp.timeIntervalSince1970 ?? 0) * 1000
        ]
        self.result?(locationMap)
        
    }
    
    public func startLocationUpdates() {
        debugPrint("startLocationUpdates method called");
        self.sendLocationUpdates = true
        self.locationManager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        self.locationManager?.startUpdatingLocation()
        self.result?([:])
    }
    
    public func stopLocationUpdates() {
        debugPrint("stopLocationUpdates method called");
        self.sendLocationUpdates = false
        self.locationManager?.stopUpdatingLocation()
        self.result?([:])
    }
    
    public func startLocationService() {
        debugPrint("startLocationService method called");
        self.sendLocationService = true
        self.locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager?.allowsBackgroundLocationUpdates = true
        self.locationManager?.pausesLocationUpdatesAutomatically = false
        self.locationManager?.distanceFilter = kCLDistanceFilterNone
        self.locationManager?.startUpdatingLocation()
        self.result?([:])
    }
    
    public func stopLocationService() {
        debugPrint("stopLocationService method called");
        self.sendLocationService = false
        self.locationManager?.stopUpdatingLocation()
        self.result?([:])
    }

    private func hasLocationPermission() -> Bool {
        let status = CLLocationManager.authorizationStatus()
        return status == .authorizedWhenInUse || status == .authorizedAlways
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            //let locationJson: [String: Any] = ["latitude": latitude, "longitude": longitude]
            let locationData =  "latitude \(latitude)\n longitude \(longitude)"
            
            debugPrint("locationManager didUpdateLocations method called \(locationData)");
            
            currentLocation = location
            
            if sendLocationUpdates || sendLocationService{
                let locationMap: [String: Any] = [
                    "latitude": self.currentLocation?.coordinate.latitude ?? 0.0,
                    "longitude": self.currentLocation?.coordinate.longitude ?? 0.0,
                    "accuracy": self.currentLocation?.horizontalAccuracy ?? 0,
                    "timestamp": (self.currentLocation?.timestamp.timeIntervalSince1970 ?? 0) * 1000
                ]
                eventSink?(locationMap)
            }
        }
    }

    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        debugPrint("Did change authorization method called");
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            performActionBasedOnMethod()
        } else if status == .denied  {
            result?("Location permission denied")
        }
    }
    
    private func checkNotificationPermissions() {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                if settings.authorizationStatus == .authorized {
                    self.showNotification()
                }else if settings.authorizationStatus == .notDetermined {
                    self.requestNotificationPermissions()
                }else{
                    self.result?("Notification permission request failed")
                }
            }
        } else {
            let settings = UIApplication.shared.currentUserNotificationSettings
            let granted = settings?.types.contains(.alert) ?? false ||
                          settings?.types.contains(.badge) ?? false ||
                          settings?.types.contains(.sound) ?? false
            
            if granted {
                self.showNotification()
            }
        }
    }
    
    private func requestNotificationPermissions() {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                if let error = error {
                    self.result?("Notification permission request failed")
                } else {
                    self.performActionBasedOnMethod()
                }
            }
        } else {
            let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
            self.performActionBasedOnMethod()
        }
    }
    
    private func showNotification() {
        if let args = arguments as? [String: Any],
           let title = args["title"] as? String,
           let message = args["message"] as? String{
                debugPrint("Title: \(title) and message: \(message)")
            
                let content = UNMutableNotificationContent()
                content.title = title
                content.body = message
                content.sound = UNNotificationSound.default
                content.categoryIdentifier = "test"

                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

                let request = UNNotificationRequest(identifier: "reminderNotification", content: content, trigger: trigger)

                UNUserNotificationCenter.current().add(request) { error in
                    if let error = error {
                        print("Error scheduling notification: \(error.localizedDescription)")
                    } else {
                        print("Notification scheduled successfully")
                    }
                }
                result?([:])
        } else {
            result?("Invalid arguments provided for notification")
        }
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
}
