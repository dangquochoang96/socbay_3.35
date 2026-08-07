import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  static Position? _lastSentPosition;
  static DateTime? _lastSentTime;

  static const String _keyLastSentTime = 'location_last_sent_time';
  static const String _keyLastSentLat = 'location_last_sent_lat';
  static const String _keyLastSentLng = 'location_last_sent_lng';

  static const int _movingTimeIntervalSeconds = 60; // Di chuyển: 1 phút (60s)
  static const int _stationaryTimeIntervalSeconds =
      3600; // Đứng yên: 60 phút (3600s)
  static const double _movementDistanceThresholdMeters =
      20.0; // Ngưỡng nhận biết di chuyển thực tế (20m)

  /// Reset bộ nhớ vị trí đã gửi
  static void resetState() {
    _lastSentPosition = null;
    _lastSentTime = null;
  }

  static Future<void> _loadLastSentState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timeStr = prefs.getString(_keyLastSentTime);
      final lat = prefs.getDouble(_keyLastSentLat);
      final lng = prefs.getDouble(_keyLastSentLng);
      if (timeStr != null && timeStr.isNotEmpty) {
        _lastSentTime = DateTime.tryParse(timeStr);
      } else {
        _lastSentTime = null;
      }
      if (lat != null && lng != null) {
        _lastSentPosition = Position(
          longitude: lng,
          latitude: lat,
          timestamp: _lastSentTime ?? DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        );
      } else {
        _lastSentPosition = null;
      }
    } catch (_) {
      _lastSentPosition = null;
      _lastSentTime = null;
    }
  }

  static Future<void> _saveLastSentState(
    Position position,
    DateTime time,
  ) async {
    _lastSentPosition = position;
    _lastSentTime = time;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyLastSentTime, time.toIso8601String());
      await prefs.setDouble(_keyLastSentLat, position.latitude);
      await prefs.setDouble(_keyLastSentLng, position.longitude);
    } catch (_) {}
  }

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    print('📍 [LOCATION BG TASK] Task started by $starter at $timestamp');
    FlutterForegroundTask.sendDataToMain({
      'type': 'status',
      'message': 'Background Task started successfully ($starter)',
    });

    // Reset state cũ khi bắt đầu ca theo dõi mới
    resetState();
    await _loadLastSentState();

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
        activityType: ActivityType.other,
        pauseLocationUpdatesAutomatically: false,
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
              '📍 [LOCATION STREAM] Lat: ${position.latitude.toStringAsFixed(6)}, Lng: ${position.longitude.toStringAsFixed(6)}, Speed: ${position.speed}m/s, Accuracy: ${position.accuracy}m',
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

    // Lấy vị trí hiện tại ban đầu ngay khi khởi chạy (có timeout để tránh treo trên Simulator)
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
    // Bỏ qua vị trí nếu độ chính xác quá kém (do nhiễu GPS lớn > 100m)
    if (position.accuracy > 100.0) {
      print(
        '⏳ [LOCATION SKIP] Bỏ qua vị trí do sai số GPS quá lớn (Accuracy: ${position.accuracy}m > 100m)',
      );
      return;
    }

    final now = DateTime.now();
    bool shouldSend = false;
    double distance = 0;
    int timeDifference = 0;

    if (_lastSentPosition == null || _lastSentTime == null) {
      // Lần đầu khởi chạy ca -> Gửi vị trí ban đầu ngay
      shouldSend = true;
    } else {
      timeDifference = now.difference(_lastSentTime!).inSeconds;
      distance = Geolocator.distanceBetween(
        _lastSentPosition!.latitude,
        _lastSentPosition!.longitude,
        position.latitude,
        position.longitude,
      );

      // Nhận biết thiết bị đang DI CHUYỂN hay ĐỨNG YÊN
      final bool hasRealSpeed = (position.speed > 0.5);
      final bool hasRealDistance = distance >= _movementDistanceThresholdMeters;
      final bool isMoving = hasRealDistance || hasRealSpeed;

      if (isMoving) {
        // ĐANG DI CHUYỂN: Cập nhật 1 phút 1 lần (>= 60s)
        if (timeDifference >= _movingTimeIntervalSeconds) {
          shouldSend = true;
        }
      } else {
        // ĐỨNG YÊN: Cập nhật 60 phút 1 lần (>= 3600s)
        if (timeDifference >= _stationaryTimeIntervalSeconds) {
          shouldSend = true;
        }
      }
    }

    if (shouldSend) {
      await _saveLastSentState(position, now);

      print(
        '🚀 [LOCATION BG SEND] Sending location update! (Dist: ${distance.toStringAsFixed(1)}m, TimeDiff: ${timeDifference}s) -> Lat: ${position.latitude.toStringAsFixed(6)}, Lng: ${position.longitude.toStringAsFixed(6)}',
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
      final bool hasRealSpeed =
          (position.speed > 1.2) && (position.accuracy <= 30.0);
      final bool hasRealDistance = distance >= _movementDistanceThresholdMeters;
      final bool isMoving = hasRealDistance || hasRealSpeed;
      print(
        '⏳ [LOCATION SKIP] Bỏ qua bản ghi (Đang ${isMoving ? "DI CHUYỂN" : "ĐỨNG YÊN"}: Dist=${distance.toStringAsFixed(1)}m, TimeDiff=${timeDifference}s - Yêu cầu: Di chuyển >= 60s, Đứng yên >= 3600s)',
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
      ).timeout(const Duration(seconds: 10));
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
