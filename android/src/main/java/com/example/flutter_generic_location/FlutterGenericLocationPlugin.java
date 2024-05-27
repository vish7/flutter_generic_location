package com.example.flutter_generic_location;

import android.Manifest;
import android.app.Activity;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.content.IntentSender;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.location.Location;
import android.net.Uri;
import android.os.Build;
import android.os.Looper;
import android.provider.Settings;
import android.util.Log;
import android.widget.Toast;

import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;
import androidx.core.app.ActivityCompat;
import androidx.core.app.NotificationCompat;
import androidx.core.content.ContextCompat;

import com.google.android.gms.common.api.ResolvableApiException;
import com.google.android.gms.location.CurrentLocationRequest;
import com.google.android.gms.location.FusedLocationProviderClient;
import com.google.android.gms.location.LocationCallback;
import com.google.android.gms.location.LocationRequest;
import com.google.android.gms.location.LocationResult;
import com.google.android.gms.location.LocationServices;
import com.google.android.gms.location.LocationSettingsRequest;
import com.google.android.gms.location.LocationSettingsResponse;
import com.google.android.gms.location.Priority;
import com.google.android.gms.location.SettingsClient;
import com.google.android.gms.tasks.CancellationToken;
import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.android.gms.tasks.OnTokenCanceledListener;
import com.google.android.gms.tasks.Task;

import org.json.JSONObject;

import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.EventChannel.EventSink;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.RequestPermissionsResultListener;

/** FlutterGenericLocationPlugin */
public class FlutterGenericLocationPlugin implements FlutterPlugin, MethodCallHandler,ActivityAware,RequestPermissionsResultListener,EventChannel.StreamHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity

  private static final String TAG = "GenericLocationAndroid";
  private Result pendingResult;
  private MethodChannel channel;
  private Context context;
  private Activity activity;
  private static final int LOCATION_PERMISSION_REQUEST_CODE = 1001;
  private FusedLocationProviderClient fusedLocationProviderClient;
  private LocationRequest locationRequest;
  private String method = "";
  private EventChannel.EventSink events;

  private String channelId = "";
  private Object arguments;
  private static final int REQUEST_NOTIFICATION_PERMISSION_CODE = 1002;

  private ActivityResultLauncher<String> backgroundLocation;

  private ActivityResultLauncher<String[]> locationPermissions;

  private final LocationCallback locationCallback = new LocationCallback() {
    @Override
    public void onLocationResult(LocationResult locationResult) {
      if (locationResult == null) {
        return;
      }

      Location location = locationResult.getLastLocation();
      if (location != null){
        Log.d(TAG, "onLocationResult: " + location.toString());
        Log.d(TAG, "onLocationResult: " + location.getLatitude());
        Log.d(TAG, "onLocationResult: " + location.getLongitude());
        if (events != null) {
          events.success(LocationService.locationToMap(location));
        }
      }
    }
  };

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) { 
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "flutter_generic_location");    
    channel.setMethodCallHandler(this);

    new EventChannel(flutterPluginBinding.getBinaryMessenger(), "flutter_generic_location_stream")
      .setStreamHandler(this);

    context = flutterPluginBinding.getApplicationContext();
    createLocationRequest();
  }

  @Override
  public void onListen(Object arguments, EventSink events) {
    this.events = events;
    LocationService.setEventSink(this.events);
  }

  @Override
  public void onCancel(Object arguments) {    
    stopLocationUpdates();
    LocationService.setEventSink(null);
  }

  @Override
  public void onAttachedToActivity(ActivityPluginBinding binding) {
    activity = binding.getActivity();
    binding.addRequestPermissionsResultListener(this);
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

  @Override
  public void onDetachedFromActivity() {
    stopLocationUpdates();
    activity = null;
  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding activityPluginBinding) {
    activity = activityPluginBinding.getActivity();
    activityPluginBinding.addRequestPermissionsResultListener(this);
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    activity = null;
  }


  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    System.out.println("On Method Called=========");
    this.pendingResult = result;
    this.method = call.method;
    this.arguments = call.arguments();

    Log.d(TAG, "onMethodCall: " + method);
    if (!hasPermission() && !method.equals("showNotification")) {
      askLocationPermission();
    }else{
      performActionBasedOnMethod();
    }
  }

  public Object argument(@NonNull String key) {
    if (arguments == null) {
      return null;
    } else if (arguments instanceof Map) {
      return (Object) ((Map<?, ?>) arguments).get(key);
    } else if (arguments instanceof JSONObject) {
      return (Object) ((JSONObject) arguments).opt(key);
    } else {
      throw new ClassCastException();
    }
  }

  private void performActionBasedOnMethod(){
    if (method.equals("getLocation")) {
      getLocation();
    }else if (method.equals("getLastLocation")) {
      getLastLocation();
    }else if (method.equals("startLocationUpdates")) {
      checkSettingsAndStartLocationUpdates();
    }else if (method.equals("stopLocationUpdates")) {
      stopLocationUpdates();
    }else if (method.equals("startLocationService")) {
      if (!hasBackgroundLocationPermission()){
        askBackgroundLocationPermission();
      }else{
        Intent intent = new Intent(context, LocationService.class);
        ContextCompat.startForegroundService(context, intent);
        pendingResult.success(new HashMap<>());
      }
    } else if (method.equals("stopLocationService")) {
      Intent intent = new Intent(context, LocationService.class);
      context.stopService(intent);
      pendingResult.success(new HashMap<>());
    }else if (method.equals("showNotification")) {
      String title = (String) argument("title");
      String message = (String) argument("message");
      this.channelId =  (String) argument("channel_id");
      byte[] imageBytes =  (byte[]) argument("image");
      if (!hasNotificaitonPermission()){
        askNotificaitonPermission();
      }else{
        showNotification(title, message,imageBytes);
        pendingResult.success(new HashMap<>());
      }
    } else {
      if (pendingResult !=  null) {
        pendingResult.notImplemented();
      }
    }
  }

  private void showNotification(String title, String message,byte[] imageBytes) {

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
      if (ContextCompat.checkSelfPermission(context, Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED) {
        ActivityCompat.requestPermissions(activity, new String[]{Manifest.permission.POST_NOTIFICATIONS}, REQUEST_NOTIFICATION_PERMISSION_CODE);
      }
    }

    NotificationManager notificationManager = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
      NotificationChannel channel = new NotificationChannel(channelId, "Default Channel", NotificationManager.IMPORTANCE_DEFAULT);
      channel.setDescription("Channel description");
      notificationManager.createNotificationChannel(channel);
    }

    Intent intent = new Intent(context, activity.getClass());
    PendingIntent pendingIntent = PendingIntent.getActivity(context, 0, intent, PendingIntent.FLAG_IMMUTABLE | PendingIntent.FLAG_UPDATE_CURRENT);

    Bitmap bitmap = BitmapFactory.decodeByteArray(imageBytes, 0, imageBytes.length);
    // Assuming you have an image in your drawable directory named 'ic_notification'
    int smallIconId = context.getResources().getIdentifier("notificaiton_icon", "drawable", context.getPackageName());


    Log.d(TAG, "Build and Show Notification");

    NotificationCompat.Builder builder = new NotificationCompat.Builder(context, channelId)
            .setSmallIcon(smallIconId)
            .setContentTitle(title)
            .setContentText(message)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setContentIntent(pendingIntent)
            .setAutoCancel(true);

    notificationManager.notify(1, builder.build());
  }


  private void createLocationRequest() {
    fusedLocationProviderClient = LocationServices.getFusedLocationProviderClient(context);
    locationRequest = new LocationRequest.Builder(Priority.PRIORITY_HIGH_ACCURACY, 100)
            .setWaitForAccurateLocation(false)
            .setMinUpdateIntervalMillis(2000)
            .setMaxUpdateDelayMillis(100)
            .build();
  }

  public boolean hasPermission() {
    return ActivityCompat.checkSelfPermission(activity, Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED;
  }

  public boolean hasNotificaitonPermission() {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
      return ActivityCompat.checkSelfPermission(activity, Manifest.permission.POST_NOTIFICATIONS) == PackageManager.PERMISSION_GRANTED;
    }
    return true;
  }

  public boolean hasBackgroundLocationPermission() {
    Log.d(TAG, "hasBackgroundLocationPermission: ");
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
      Log.d(TAG, "Permission Exists Or Not: ");
      return ActivityCompat.checkSelfPermission(activity, Manifest.permission.ACCESS_BACKGROUND_LOCATION) == PackageManager.PERMISSION_GRANTED;
    }
    return true;
  }

  private void checkSettingsAndStartLocationUpdates() {
    LocationSettingsRequest request = new LocationSettingsRequest.Builder()
            .addLocationRequest(locationRequest).build();
    SettingsClient client = LocationServices.getSettingsClient(context);

    Task<LocationSettingsResponse> locationSettingsResponseTask = client.checkLocationSettings(request);
    locationSettingsResponseTask.addOnSuccessListener(new OnSuccessListener<LocationSettingsResponse>() {
      @Override
      public void onSuccess(LocationSettingsResponse locationSettingsResponse) {
        //Settings of device are satisfied and we can start location updates        
        startLocationUpdates();
      }
    });

    locationSettingsResponseTask.addOnFailureListener(new OnFailureListener() {
      @Override
      public void onFailure(@NonNull Exception e) {
        pendingResult.error("LOCATION_FAILED", e.getMessage(), null);
        if (e instanceof ResolvableApiException) {
          ResolvableApiException apiException = (ResolvableApiException) e;
          try {
            apiException.startResolutionForResult(activity, 1001);
          } catch (IntentSender.SendIntentException ex) {
            ex.printStackTrace();
          }
        }
      }
    });
  }

  private void startLocationUpdates() {
    fusedLocationProviderClient.requestLocationUpdates(locationRequest, locationCallback, Looper.getMainLooper());
    pendingResult.success(new HashMap<>());
  }

  private void stopLocationUpdates() {
    fusedLocationProviderClient.removeLocationUpdates(locationCallback);
    pendingResult.success(new HashMap<>());
  }

  private void getLocation() {
    Log.d(TAG, "getLocation: Called");
    
    if (pendingResult == null){
      Log.d(TAG, "pendingResult is Null");
      return;
    }

    fusedLocationProviderClient.getCurrentLocation(Priority.PRIORITY_HIGH_ACCURACY, null)
    .addOnCompleteListener(new OnCompleteListener<Location>() {
      @Override
      public void onComplete(@NonNull Task<Location> task) {
        if (task.isSuccessful() && task.getResult() != null) {
          Location location = task.getResult();
          if (location != null) {
            //We have a location
            Log.d(TAG, "onSuccess: " + location.toString());
            Log.d(TAG, "onSuccess: " + location.getLatitude());
            Log.d(TAG, "onSuccess: " + location.getLongitude());
            pendingResult.success(LocationService.locationToMap(location));
          } else  {
            pendingResult.error("LOCATION_FAILED", "Unable to fetch location", null);
          }
        } else {
          pendingResult.error("LOCATION_FAILED", "Unable to fetch location", null);
        }
      }
    });
  }

  private void getLastLocation() {
    Log.d(TAG, "getLastLocation: Called");
    
    if (pendingResult == null){
      Log.d(TAG, "pendingResult is Null");
      return;
    }

    Task<Location> locationTask = fusedLocationProviderClient.getLastLocation();
    locationTask.addOnSuccessListener(new OnSuccessListener<Location>() {
      @Override
      public void onSuccess(Location location) {
        if (location != null) {
          //We have a location
          Log.d(TAG, "onSuccess: " + location.toString());
          Log.d(TAG, "onSuccess: " + location.getLatitude());
          Log.d(TAG, "onSuccess: " + location.getLongitude());
          pendingResult.success(LocationService.locationToMap(location));
        } else  {
          pendingResult.error("LOCATION_FAILED", "Unable to fetch location", null);
        }
      }
    });
    locationTask.addOnFailureListener(new OnFailureListener() {
      @Override
      public void onFailure(@NonNull Exception e) {
        Log.e(TAG, "onFailure: " + e.getLocalizedMessage() );
        pendingResult.error("LOCATION_FAILED", e.getLocalizedMessage(), null);
      }
    });
  }

  private void askLocationPermission() {
    if (ContextCompat.checkSelfPermission(activity, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
      if (ActivityCompat.shouldShowRequestPermissionRationale(activity, Manifest.permission.ACCESS_FINE_LOCATION)) {
        Log.d(TAG, "askLocationPermission: you should show an alert dialog...");
        ActivityCompat.requestPermissions(activity, new String[] {Manifest.permission.ACCESS_FINE_LOCATION}, LOCATION_PERMISSION_REQUEST_CODE);
      } else {
        ActivityCompat.requestPermissions(activity, new String[] {Manifest.permission.ACCESS_FINE_LOCATION}, LOCATION_PERMISSION_REQUEST_CODE);
      }
    }
  }

  private void askBackgroundLocationPermission() {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
      if (ContextCompat.checkSelfPermission(activity, Manifest.permission.ACCESS_BACKGROUND_LOCATION) != PackageManager.PERMISSION_GRANTED) {
        if (ActivityCompat.shouldShowRequestPermissionRationale(activity, Manifest.permission.ACCESS_BACKGROUND_LOCATION)) {
          Log.d(TAG, "askBackgroundLocationPermission: you should show an alert dialog...");          
          ActivityCompat.requestPermissions(activity, new String[] {Manifest.permission.ACCESS_BACKGROUND_LOCATION}, LOCATION_PERMISSION_REQUEST_CODE);
        } else {
          ActivityCompat.requestPermissions(activity, new String[] {Manifest.permission.ACCESS_BACKGROUND_LOCATION}, LOCATION_PERMISSION_REQUEST_CODE);
        }
      }
    }

  }


  private void askNotificaitonPermission() {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
      if (ContextCompat.checkSelfPermission(activity, Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED) {
        if (ActivityCompat.shouldShowRequestPermissionRationale(activity, Manifest.permission.POST_NOTIFICATIONS)) {
          Log.d(TAG, "askLocationPermission: you should show an alert dialog...");
          ActivityCompat.requestPermissions(activity, new String[] {Manifest.permission.POST_NOTIFICATIONS}, REQUEST_NOTIFICATION_PERMISSION_CODE);
        } else {
          ActivityCompat.requestPermissions(activity, new String[] {Manifest.permission.POST_NOTIFICATIONS}, REQUEST_NOTIFICATION_PERMISSION_CODE);
        }
      }
    }
  }

  
  @Override
  public boolean onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
    Toast.makeText(context,"onRequestPermissionsResult=====",Toast.LENGTH_LONG).show();
    if (requestCode == LOCATION_PERMISSION_REQUEST_CODE) {
        if (grantResults != null && grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {      
          performActionBasedOnMethod();
        }
        return true;
    }else if (requestCode == REQUEST_NOTIFICATION_PERMISSION_CODE) {
      if (grantResults != null && grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
        performActionBasedOnMethod();
      }
      return true;
    }
    return false;
  }
}
