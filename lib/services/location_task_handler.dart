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
  static Position? _lastRecordedPosition;
  static double _totalDistance = 0.0; // mét

  static const String _keyLastSentTime = 'location_last_sent_time';
  static const String _keyLastSentLat = 'location_last_sent_lat';
  static const String _keyLastSentLng = 'location_last_sent_lng';

  static const int _movingTimeIntervalSeconds = 30; // Di chuyển: gửi cập nhật mỗi 30s
  static const int _stationaryHeartbeatSeconds = 300; // Đứng yên: gửi heartbeat mỗi 5 phút (300s)
  static const double _movementDistanceThresholdMeters = 20.0; // Ngưỡng nhận biết di chuyển
  static const double _forceSendDistanceMeters = 100.0; // Di chuyển quá 100m gửi ngay

  /// Reset bộ nhớ vị trí đã gửi và quãng đường
  static void resetState() {
    _lastSentPosition = null;
    _lastSentTime = null;
    _lastRecordedPosition = null;
    _totalDistance = 0.0;
  }

  static Future<void> _loadLastSentState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.reload();
      final timeStr = prefs.getString(_keyLastSentTime);
      final lat = prefs.getDouble(_keyLastSentLat);
      final lng = prefs.getDouble(_keyLastSentLng);
      _totalDistance = prefs.getDouble(LocationApiService.keyTotalDistance) ?? 0.0;

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
        _lastRecordedPosition = _lastSentPosition;
      } else {
        _lastSentPosition = null;
        _lastRecordedPosition = null;
      }
    } catch (_) {
      _lastSentPosition = null;
      _lastSentTime = null;
      _lastRecordedPosition = null;
      _totalDistance = 0.0;
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
      await prefs.setDouble(LocationApiService.keyTotalDistance, _totalDistance);
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
        distanceFilter: 10,
        intervalDuration: const Duration(seconds: 10),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      locationSettings = AppleSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
        activityType: ActivityType.automotiveNavigation,
        pauseLocationUpdatesAutomatically: false,
        allowBackgroundLocationUpdates: true,
        showBackgroundLocationIndicator: true,
      );
    } else {
      locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
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
    // Bỏ qua vị trí nếu độ chính xác quá kém (do nhiễu GPS lớn > 50m)
    if (position.accuracy > 50.0) {
      print(
        '⏳ [LOCATION SKIP] Bỏ qua vị trí do sai số GPS lớn (Accuracy: ${position.accuracy}m > 50m)',
      );
      return;
    }

    final now = DateTime.now();

    // 1. TÍNH TOÁN QUÃNG ĐƯỜNG TÍCH LŨY (MÉT)
    double stepDistance = 0.0;
    if (_lastRecordedPosition != null) {
      stepDistance = Geolocator.distanceBetween(
        _lastRecordedPosition!.latitude,
        _lastRecordedPosition!.longitude,
        position.latitude,
        position.longitude,
      );

      // Lọc hiện tượng GPS trôi (GPS drift/jitter) khi đứng yên một chỗ (< 5m và speed < 0.5m/s)
      if (stepDistance >= 5.0 || position.speed >= 0.6) {
        _totalDistance += stepDistance;
        _lastRecordedPosition = position;
        LocationApiService.saveTotalDistance(_totalDistance);
      }
    } else {
      _lastRecordedPosition = position;
    }

    // 2. KIỂM TRA ĐIỀU KIỆN GỬI BẢN GHI LÊN SERVER
    bool shouldSend = false;
    double distFromLastSent = 0.0;
    int timeDifference = 0;

    if (_lastSentPosition == null || _lastSentTime == null) {
      // Lần đầu khởi chạy ca -> Gửi vị trí ban đầu ngay
      shouldSend = true;
    } else {
      timeDifference = now.difference(_lastSentTime!).inSeconds;
      distFromLastSent = Geolocator.distanceBetween(
        _lastSentPosition!.latitude,
        _lastSentPosition!.longitude,
        position.latitude,
        position.longitude,
      );

      // Nhận biết thiết bị đang DI CHUYỂN hay ĐỨNG YÊN
      final bool hasRealSpeed = (position.speed >= 0.8);
      final bool hasRealDistance = distFromLastSent >= _movementDistanceThresholdMeters;
      final bool isMoving = hasRealDistance || hasRealSpeed;

      if (distFromLastSent >= _forceSendDistanceMeters) {
        // Di chuyển được khoảng cách lớn (>= 100m) -> gửi ngay
        shouldSend = true;
      } else if (isMoving) {
        // ĐANG DI CHUYỂN: Gửi cập nhật định kỳ mỗi 30s
        if (timeDifference >= _movingTimeIntervalSeconds) {
          shouldSend = true;
        }
      } else {
        // ĐỨNG YÊN: Gửi heartbeat định kỳ mỗi 5 phút (300s)
        if (timeDifference >= _stationaryHeartbeatSeconds) {
          shouldSend = true;
        }
      }
    }

    if (shouldSend) {
      await _saveLastSentState(position, now);

      final double totalKm = _totalDistance / 1000.0;
      print(
        '🚀 [LOCATION BG SEND] Sending location update! (DistStep: ${distFromLastSent.toStringAsFixed(1)}m, Total: ${totalKm.toStringAsFixed(2)}km, TimeDiff: ${timeDifference}s) -> Lat: ${position.latitude.toStringAsFixed(6)}, Lng: ${position.longitude.toStringAsFixed(6)}',
      );

      // 1. Lấy dung lượng pin & trip_id đã lưu
      final int batteryLevel = await LocationApiService.getBatteryLevel();
      final dynamic tripId = await LocationApiService.getSavedTripId();
      final String recordedAt = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

      // 2. Gọi API updateLocation kèm khoảng cách chặng và tổng quãng đường
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
        distance: distFromLastSent,
        totalDistance: _totalDistance,
      );

      // 3. Cập nhật thông báo trực tiếp trên thanh trạng thái Notification
      FlutterForegroundTask.updateService(
        notificationTitle: 'Đang theo dõi ca làm việc',
        notificationText:
            'Đã di chuyển: ${totalKm.toStringAsFixed(2)} km | Tọa độ: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}',
      );

      // 4. Gửi dữ liệu vị trí và quãng đường sang Main Isolate
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
        'distance_step': distFromLastSent,
        'total_distance': _totalDistance,
        'timestamp': position.timestamp.millisecondsSinceEpoch,
      });
    }
  }

  @override
  void onRepeatEvent(DateTime timestamp) async {
    final now = DateTime.now();

    if (_lastSentTime == null ||
        now.difference(_lastSentTime!).inSeconds >= _movingTimeIntervalSeconds) {
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
