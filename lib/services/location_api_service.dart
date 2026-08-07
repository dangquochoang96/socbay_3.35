import 'dart:convert';
import 'package:battery_plus/battery_plus.dart';
import 'package:socbay/config/app_config.dart';
import 'package:socbay/data/data_provider/api_endpoints.dart';
import 'package:socbay/services/location_task_handler.dart';
import 'package:socbay/utils/auth_http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LocationApiService {
  static const String keyTripId = 'current_location_trip_id';

  /// Ham lay ApiUrl an toan ke ca khi chay trong Isolate ngam (noi AppConfig.instance chua duoc khoi tao)
  static String getApiUrl(String endpoint) {
    try {
      return AppConfig.instance.apiUrl(endpoint);
    } catch (_) {
      final cleanEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
      return 'https://api.iongeyser.com/api/v1.0$cleanEndpoint';
    }
  }

  /// Lay dung luong pin hien tai (0-100)
  static Future<int> getBatteryLevel() async {
    try {
      final battery = Battery();
      return await battery.batteryLevel;
    } catch (_) {
      return 100;
    }
  }

  /// Luu trip_id vao SharedPreferences
  static Future<void> saveTripId(dynamic tripId) async {
    final prefs = await SharedPreferences.getInstance();
    if (tripId == null) {
      await prefs.remove(keyTripId);
    } else {
      await prefs.setString(keyTripId, tripId.toString());
    }
  }

  /// Lay trip_id tu SharedPreferences
  static Future<dynamic> getSavedTripId() async {
    final prefs = await SharedPreferences.getInstance();
    final val = prefs.getString(keyTripId);
    if (val == null || val.isEmpty) return null;
    return int.tryParse(val) ?? val;
  }

  /// 1. Goi API Bắt đầu ca / Trip
  static Future<dynamic> startTrip({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final url = Uri.parse(getApiUrl(ApiEndpoints.startTrip));
      final body = {'latitude': latitude, 'longitude': longitude};

      print('📡 [LOCATION API] Calling startTrip: $url - Body: $body');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      print(
        '📡 [LOCATION API] startTrip status: ${response.statusCode}, body: ${response.body}',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final res = jsonDecode(response.body);
        dynamic tripId;
        if (res is Map) {
          final data = res['data'] ?? res;
          if (data is Map) {
            tripId = data['id'] ?? data['trip_id'];
          } else {
            tripId = data;
          }
        }
        if (tripId != null) {
          await saveTripId(tripId);
        }
        return tripId;
      }
    } catch (e, stackTrace) {
      print('❌ [LOCATION API ERROR] startTrip failed: $e\n$stackTrace');
    }
    return null;
  }

  /// 2. Goi API Cap nhat vi tri trong ca (updateLocation)
  static Future<bool> updateLocation({
    required double latitude,
    required double longitude,
    required double speed,
    required double heading,
    required double accuracy,
    required int battery,
    required bool isMock,
    required dynamic tripId,
    required String recordedAt,
  }) async {
    try {
      final url = Uri.parse(getApiUrl(ApiEndpoints.updateLocation));
      final body = {
        'latitude': latitude,
        'longitude': longitude,
        'speed': speed,
        'heading': heading,
        'accuracy': accuracy,
        'battery': battery,
        'is_mock': isMock,
        'trip_id': tripId,
        'recorded_at': recordedAt,
      };

      print('📡 [LOCATION API] Calling updateLocation: $url - Body: $body');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      print(
        '📡 [LOCATION API] updateLocation status: ${response.statusCode}, body: ${response.body}',
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e, stackTrace) {
      print('❌ [LOCATION API ERROR] updateLocation failed: $e\n$stackTrace');
      return false;
    }
  }

  /// Xoa thong tin thoi gian gui vi tri cuoi cung
  static Future<void> clearLastSentState() async {
    try {
      LocationTaskHandler.resetState();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('location_last_sent_time');
      await prefs.remove('location_last_sent_lat');
      await prefs.remove('location_last_sent_lng');
    } catch (_) {}
  }

  /// 3. Goi API Ket thuc ca / Stop Trip
  static Future<bool> stopTrip({
    dynamic tripId,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final effectiveTripId = tripId ?? await getSavedTripId();
      final url = Uri.parse(getApiUrl(ApiEndpoints.stopTrip));
      final body = <String, dynamic>{
        if (effectiveTripId != null) 'trip_id': effectiveTripId,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      };

      print('📡 [LOCATION API] Calling stopTrip: $url - Body: $body');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      print(
        '📡 [LOCATION API] stopTrip status: ${response.statusCode}, body: ${response.body}',
      );
      await saveTripId(null);
      await clearLastSentState();
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('❌ [LOCATION API ERROR] stopTrip failed: $e');
      await saveTripId(null);
      await clearLastSentState();
      return false;
    }
  }
}
