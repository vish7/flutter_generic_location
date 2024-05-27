package com.example.flutter_generic_location;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.Service;
import android.content.Intent;
import android.location.Location;
import android.os.Build;
import android.os.IBinder;

import androidx.core.app.NotificationCompat;

import com.google.android.gms.location.FusedLocationProviderClient;
import com.google.android.gms.location.LocationCallback;
import com.google.android.gms.location.LocationRequest;
import com.google.android.gms.location.LocationResult;
import com.google.android.gms.location.LocationServices;
import com.google.android.gms.location.Priority;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.EventChannel;

public class LocationService extends Service {

    private static final String CHANNEL_ID = "12345";
    private static final int NOTIFICATION_ID = 12345;

    private FusedLocationProviderClient fusedLocationProviderClient;
    private LocationCallback locationCallback;
    private LocationRequest locationRequest;

    private NotificationManager notificationManager;

    private Location location;

    private static EventChannel.EventSink events;

    @Override
    public void onCreate() {
        super.onCreate();

        fusedLocationProviderClient = LocationServices.getFusedLocationProviderClient(this);
        locationRequest = new LocationRequest.Builder(Priority.PRIORITY_HIGH_ACCURACY, 100)
            .setWaitForAccurateLocation(false)
            .setMinUpdateIntervalMillis(2000)
            .setMaxUpdateDelayMillis(100)
            .build();
            
        locationCallback = new LocationCallback() {
            @Override
            public void onLocationAvailability(com.google.android.gms.location.LocationAvailability p0) {
                super.onLocationAvailability(p0);
            }

            @Override
            public void onLocationResult(LocationResult locationResult) {
                super.onLocationResult(locationResult);
                onNewLocation(locationResult);
            }
        };
        notificationManager = (NotificationManager) this.getSystemService(NOTIFICATION_SERVICE);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel notificationChannel = new NotificationChannel(CHANNEL_ID, "locations", NotificationManager.IMPORTANCE_HIGH);
            notificationManager.createNotificationChannel(notificationChannel);
        }
    }

    @SuppressWarnings("MissingPermission")
    private void createLocationRequest() {
        try {
            fusedLocationProviderClient.requestLocationUpdates(
                    locationRequest, locationCallback, null
            );
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void removeLocationUpdates() {
        if (locationCallback != null) {
            fusedLocationProviderClient.removeLocationUpdates(locationCallback);
        }
        stopForeground(true);
        stopSelf();
    }

    private void onNewLocation(LocationResult locationResult) {
        location = locationResult.getLastLocation();
        if (events != null && location  != null) {
            events.success(locationToMap(location));
        }
        startForeground(NOTIFICATION_ID, getNotification());
    }

    public static Map<String, Object> locationToMap(Location location) {
        Map<String, Object> map = new HashMap<>();
        map.put("latitude", location.getLatitude());
        map.put("longitude", location.getLongitude());
        map.put("accuracy", location.getAccuracy());
        map.put("timestamp", location.getTime());
        return map;
    }


    private Notification getNotification() {
        int smallIconId = getResources().getIdentifier("notificaiton_icon", "drawable", getPackageName());
        NotificationCompat.Builder notification = new NotificationCompat.Builder(this, CHANNEL_ID)
                .setContentTitle("Location Updates")
                .setContentText(
                        "Latitude--> " + location.getLatitude() + "\nLongitude --> " + location.getLongitude()
                )
                .setSmallIcon(smallIconId)
                .setPriority(NotificationCompat.PRIORITY_HIGH)
                .setOngoing(true);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            notification.setChannelId(CHANNEL_ID);
        }
        return notification.build();
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        super.onStartCommand(intent, flags, startId);
        createLocationRequest();
        return START_STICKY;
    }

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        removeLocationUpdates();
    }

    public static void setEventSink(EventChannel.EventSink sink) {
        events  = sink;
    }
}

