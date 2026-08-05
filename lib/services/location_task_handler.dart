import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:socbay/config/app_config.dart';
import 'package:socbay/services/location_api_service.dart';

@pragma('vm:entry-point')
void startCallback() {
  WidgetsFlutterBinding.ensureInitialized();
  AppConfig(Flavor.development, '');
  FlutterForegroundTask.setTaskHandler(LocationTaskHandler());
}

class LocationTaskHandler extends TaskHandler {
  StreamSubscription<Position>? _positionSubscription;
  Position? _lastSentPosition;
  DateTime? _lastSentTime;

  static const int _movingTimeIntervalSeconds = 60; // Di chuyen: 1 phut (60s)
  static const int _stationaryTimeIntervalSeconds =
      3600; // Dung yen: 60 phut (3600s)
  static const double _movementDistanceThresholdMeters =
      15.0; // Nguong nhan biet di chuyen (15m)

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    print('📍 [LOCATION BG TASK] Task started by $starter at $timestamp');
    FlutterForegroundTask.sendDataToMain({
      'type': 'status',
      'message': 'Background Task started successfully ($starter)',
    });

    late final LocationSettings locationSettings;
    if (defaultTargetPlatform == TargetPlatform.android) {
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 15,
        intervalDuration: const Duration(seconds: 10),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      locationSettings = AppleSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 15,
        activityType: ActivityType.fitness,
        allowBackgroundLocationUpdates: true,
        showBackgroundLocationIndicator: true,
      );
    } else {
      locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 15,
      );
    }

    _positionSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (Position position) {
            print(
              '📍 [LOCATION STREAM] Lat: ${position.latitude.toStringAsFixed(6)}, Lng: ${position.longitude.toStringAsFixed(6)}, Speed: ${position.speed}m/s',
            );
            _handleLocationUpdate(position);
          },
          onError: (error) {
            print('❌ [LOCATION STREAM ERROR] $error');
            FlutterForegroundTask.sendDataToMain({
              'type': 'error',
              'message': 'Location Stream Error: $error',
            });
          },
        );

    // Lay vi tri hien tai ban dau ngay khi khoi chay (co timeout de tranh treo tren Simulator)
    try {
      Position currentPos = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      ).timeout(const Duration(seconds: 10));
      print(
        '📍 [LOCATION INITIAL] Current position: (${currentPos.latitude}, ${currentPos.longitude})',
      );
      _handleLocationUpdate(currentPos);
    } catch (e) {
      print('❌ [LOCATION INITIAL ERROR] $e');
      FlutterForegroundTask.sendDataToMain({
        'type': 'error',
        'message': 'Initial Position Error / Simulator GPS None: $e',
      });
    }
  }

  Future<void> _handleLocationUpdate(Position position) async {
    final now = DateTime.now();
    bool shouldSend = false;
    double distance = 0;
    int timeDifference = 0;

    if (_lastSentPosition == null || _lastSentTime == null) {
      // Lan dau khoi chay ca -> Gui vi tri ban dau ngay
      shouldSend = true;
    } else {
      timeDifference = now.difference(_lastSentTime!).inSeconds;
      distance = Geolocator.distanceBetween(
        _lastSentPosition!.latitude,
        _lastSentPosition!.longitude,
        position.latitude,
        position.longitude,
      );

      // Nhan biet thiet bi dang DI CHUYEN hay ĐỨNG YÊN
      final bool isMoving =
          (distance >= _movementDistanceThresholdMeters) ||
          (position.speed > 0.5);

      if (isMoving) {
        // ĐANG DI CHUYỂN: Cap nhat 1 phut 1 lan (>= 60s)
        if (timeDifference >= _movingTimeIntervalSeconds) {
          shouldSend = true;
        }
      } else {
        // ĐỨNG YÊN: Cap nhat 5 phut 1 lan (>= 300s)
        if (timeDifference >= _stationaryTimeIntervalSeconds) {
          shouldSend = true;
        }
      }
    }

    if (shouldSend) {
      _lastSentPosition = position;
      _lastSentTime = now;

      print(
        '🚀 [LOCATION BG SEND] Sending location update! (Dist: ${distance.toStringAsFixed(1)}m, TimeDiff: ${timeDifference}s, IsMoving: ${(distance >= _movementDistanceThresholdMeters) || (position.speed > 0.5)}) -> Lat: ${position.latitude.toStringAsFixed(6)}, Lng: ${position.longitude.toStringAsFixed(6)}',
      );

      // 1. Lay dung luong pin & trip_id da luu
      final int batteryLevel = await LocationApiService.getBatteryLevel();
      final dynamic tripId = await LocationApiService.getSavedTripId();
      final String recordedAt = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

      // 2. Goi API updateLocation
      await LocationApiService.updateLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        speed: position.speed,
        heading: position.heading,
        accuracy: position.accuracy,
        battery: batteryLevel,
        isMock: position.isMocked == true,
        tripId: tripId,
        recordedAt: recordedAt,
      );

      // 3. Cap nhat thong bao tren thanh trang thai Android
      FlutterForegroundTask.updateService(
        notificationTitle: 'Đang theo dõi vị trí kỹ thuật viên',
        notificationText:
            'Tọa độ: ${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}',
      );

      // 4. Gui du lieu vi tri sang Main Isolate
      FlutterForegroundTask.sendDataToMain({
        'latitude': position.latitude,
        'longitude': position.longitude,
        'speed': position.speed,
        'heading': position.heading,
        'accuracy': position.accuracy,
        'battery': batteryLevel,
        'is_mock': position.isMocked,
        'trip_id': tripId,
        'recorded_at': recordedAt,
        'timestamp': position.timestamp.millisecondsSinceEpoch,
      });
    } else {
      final bool isMoving =
          (distance >= _movementDistanceThresholdMeters) ||
          (position.speed > 0.5);
      print(
        '⏳ [LOCATION SKIP] Bỏ qua bản ghi (Đang ${isMoving ? "DI CHUYỂN" : "ĐỨNG YÊN"}: Dist=${distance.toStringAsFixed(1)}m, TimeDiff=${timeDifference}s - Yêu cầu: Di chuyển >= 60s, Đứng yên >= 3600s (60 phút))',
      );
    }
  }

  @override
  void onRepeatEvent(DateTime timestamp) async {
    final now = DateTime.now();

    if (_lastSentTime == null ||
        now.difference(_lastSentTime!).inSeconds >=
            _movingTimeIntervalSeconds) {
      print(
        '🔄 [LOCATION BG REPEAT] Event triggered at $timestamp (Checking location update...)',
      );
      _fetchAndSendCurrentLocation();
    }
  }

  Future<void> _fetchAndSendCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      ).timeout(const Duration(seconds: 5));
      _handleLocationUpdate(position);
    } catch (e) {
      print('❌ [LOCATION REPEAT ERROR] $e');
    }
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    print(
      '🛑 [LOCATION BG TASK] Task destroyed (isTimeout: $isTimeout) at $timestamp',
    );
    await _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  @override
  void onNotificationButtonPressed(String id) {}

  @override
  void onNotificationDismissed() {}
}
