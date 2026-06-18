// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert';
import 'dart:convert' as convert;

import 'package:http/http.dart' as _http;
import 'package:socbay/utils/secure_storage_utils.dart';

export 'package:http/http.dart' hide MultipartRequest, delete, get, post, put;

Future<Map<String, String>> _buildHeaders([
  Map<String, String>? headers,
]) async {
  final mergedHeaders = <String, String>{
    'Accept': 'application/json',
    ...?headers,
  };

  final token = await SecureStorageUtil.shared.readData(
    SecureStorageUtil.tokenStorageKey,
  );
  if ((token ?? '').isNotEmpty && !mergedHeaders.containsKey('Authorization')) {
    mergedHeaders['Authorization'] = 'Bearer $token';
  }

  return mergedHeaders;
}

Object? _normalizeBody(Object? body, Map<String, String> headers) {
  if (body is Map &&
      (headers['Content-Type']?.contains('application/json') ?? false)) {
    return convert.jsonEncode(body);
  }
  return body;
}

Future<_http.Response> get(Uri url, {Map<String, String>? headers}) async {
  return _http.get(url, headers: await _buildHeaders(headers));
}

Future<_http.Response> post(
  Uri url, {
  Map<String, String>? headers,
  Object? body,
  Encoding? encoding,
}) async {
  final mergedHeaders = await _buildHeaders(headers);
  return _http.post(
    url,
    headers: mergedHeaders,
    body: _normalizeBody(body, mergedHeaders),
    encoding: encoding,
  );
}

Future<_http.Response> put(
  Uri url, {
  Map<String, String>? headers,
  Object? body,
  Encoding? encoding,
}) async {
  final mergedHeaders = await _buildHeaders(headers);
  return _http.put(
    url,
    headers: mergedHeaders,
    body: _normalizeBody(body, mergedHeaders),
    encoding: encoding,
  );
}

Future<_http.Response> delete(
  Uri url, {
  Map<String, String>? headers,
  Object? body,
  Encoding? encoding,
}) async {
  final mergedHeaders = await _buildHeaders(headers);
  return _http.delete(
    url,
    headers: mergedHeaders,
    body: _normalizeBody(body, mergedHeaders),
    encoding: encoding,
  );
}

class MultipartRequest extends _http.MultipartRequest {
  MultipartRequest(super.method, super.url, {Map<String, String>? headers}) {
    if (headers != null) {
      this.headers.addAll(headers);
    }
  }

  @override
  Future<_http.StreamedResponse> send() async {
    headers.addAll(await _buildHeaders(headers));
    return super.send();
  }
}
