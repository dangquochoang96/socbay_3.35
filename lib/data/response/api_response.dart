import 'dart:io';

import 'package:socbay/constants/api_key_param.dart';
import 'package:socbay/utils/parse_util.dart';

abstract class BaseResponse {
  BaseResponse();

  BaseResponse.fromJson(Map<String, dynamic> json);

  BaseResponse.withError(Error error);
}

class DefaultResponse<T> extends BaseResponse {
  T? data;
  int? status;
  String? message;
  //int total = 0;

  DefaultResponse({
    this.data,
    this.status = 1,
    this.message,
    //this.total = 0,
  });

  DefaultResponse.fromMap(Map<dynamic, dynamic> json) {
    if (json['status'] != null) {
      status = Parse.toIntValue(json['status']);
    }

    if (json['data'] != null) {
      data = json['data'] as T;
    }
    if (json['message'] != null) {
      message = json['message'];
    }
    // if (json['total'] != null) {
    //   total = Parse.toIntValue(json['total']);
    // }
  }

  DefaultResponse.fromJson(Map<dynamic, dynamic> json) {
    data = json['data'] as T;
    message = json['message'] as String;
    status = Parse.toIntValue(json['code']);
    //total = Parse.toIntValue(json['total']);
  }

  DefaultResponse.withError(Error err) {
    data = null;
    status = HttpStatus.internalServerError;
    message = "Error";
  }

  Map<String, dynamic> toJson() {
    return {ApiKeyParam.result: data, 'code': status};
  }
}

class Error {
  String message = '';
  int code = 0;

  Error({required this.message, code = 0});

  Error.fromJson(Map<String, dynamic> json) {
    message = json['message'] ?? '';
    code = json['code'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    return {'message': message, 'code': code};
  }
}
