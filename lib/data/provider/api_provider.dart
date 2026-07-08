import 'dart:convert';
import 'dart:io';
import 'package:socbay/utils/auth_http.dart' as http;

import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:socbay/application.dart';
import 'package:socbay/config/app_config.dart';
import 'package:socbay/data/data_provider/api_endpoints.dart';
import 'package:socbay/data/data_provider/api_manager.dart';
import 'package:socbay/data/data_provider/base_api.dart';
import 'package:socbay/data/model/banner_model.dart';
import 'package:socbay/data/model/blog_model.dart';
import 'package:socbay/data/model/gift_response.dart';
import 'package:socbay/data/model/home_service_model.dart';
import 'package:socbay/data/model/login_response.dart';
import 'package:socbay/data/model/notification_response.dart';
import 'package:socbay/data/model/product_category.dart';
import 'package:socbay/data/model/product_model.dart';
import 'package:socbay/data/model/request/change_password_request.dart';
import 'package:socbay/data/model/request/create_task_request.dart';
import 'package:socbay/data/model/request/new_password_request.dart';
import 'package:socbay/data/model/request/register_request_model.dart';
import 'package:socbay/data/model/request/staff_by_distance_request.dart';
import 'package:socbay/data/model/request/update_staff_request_model.dart';
import 'package:socbay/data/model/request/update_task_request.dart';
import 'package:socbay/data/model/request/user_address_request.dart';
import 'package:socbay/data/model/request/user_info_request.dart';
import 'package:socbay/data/model/task_model.dart';
import 'package:socbay/data/model/user_address.dart';
import 'package:socbay/data/model/user_model.dart';
import 'package:socbay/data/model/kpi_model.dart';
import 'package:socbay/data/model/user_profile.dart';
import 'package:socbay/data/model/user_attendance_model.dart';
import 'package:socbay/data/model/wallet_model.dart';
import 'package:socbay/data/response/api_response.dart';
import 'package:socbay/utils/logger_util.dart';

import 'package:path/path.dart' as path_manager;

class ApiProvider {
  final BaseAPI _baseAPI;

  ApiProvider(this._baseAPI);

  Future<DefaultResponse> setOTP(String phoneNumber) async {
    try {
      var dio = Dio();
      var response = await dio.post(
        AppConfig.instance.apiUrl(ApiEndpoints.setOtp),
        data: {'phone': phoneNumber},
        options: Options(contentType: 'application/json'),
      );
      // print(json.decode(response.toString()));
      var res = Map<String, dynamic>.from(jsonDecode(response.toString()));
      // final res = response.data;
      if (res["code"] != null && res["code"] == 1 && res["data"] != null) {
        return DefaultResponse(data: res["data"]);
      } else {
        return DefaultResponse(message: res["message"]);
      }
    } catch (e) {
      return DefaultResponse.withError(Error(message: e.toString()));
    }
  }

  Future<DefaultResponse<LoginResponse>> login(
    String phone,
    String password, [
    String? fcmToken,
  ]) async {
    try {
      LoggerUtil.info('login() request phone=$phone', tag: 'ApiProvider');
      final bodyParams = {
        "phone": phone,
        "pass": password,
        if (fcmToken != null && fcmToken.isNotEmpty) "fcm_token": fcmToken,
      };
      final Map resJson = await _baseAPI.request(
        manager: ApiManager(ApiType.login),
        bodyParams: bodyParams,
      );
      LoggerUtil.info('login() raw response=$resJson', tag: 'ApiProvider');
      final res = DefaultResponse.fromJson(Map<String, dynamic>.from(resJson));
      LoggerUtil.info(
        'login() parsed status=${res.status} message=${res.message} hasData=${res.data != null}',
        tag: 'ApiProvider',
      );
      if (res.status == 1 && res.data != null) {
        final item = LoginResponse.fromJson(res.data);
        LoggerUtil.info(
          'login() parsed loginResponse tokenPresent=${(item.accessToken ?? '').isNotEmpty} userId=${item.user?.id}',
          tag: 'ApiProvider',
        );
        print("login response ${res.data}");
        return DefaultResponse(data: item, status: 200, message: res.message);
      } else {
        LoggerUtil.warning(
          'login() failed status=${res.status} message=${res.message}',
          tag: 'ApiProvider',
        );
        return DefaultResponse(status: res.status, message: res.message);
      }
    } catch (e) {
      LoggerUtil.error('login() exception=$e', tag: 'ApiProvider');
      return DefaultResponse.withError(Error(message: e.toString()));
    }
  }

  Future<DefaultResponse> register(
    RegisterRequestModel registerRequestModel,
  ) async {
    try {
      final Map resJson = await _baseAPI.request(
        manager: ApiManager(ApiType.register),
        isUseAccessToken: false,
        bodyParams: {
          "username": registerRequestModel.username,
          "phone": registerRequestModel.phone,
          "password": registerRequestModel.password,
          "otp": registerRequestModel.otp,
        },
      );
      final res = DefaultResponse.fromMap(resJson);
      if (res.status == 200 && res.data != null) {
        return DefaultResponse(data: res.data);
      } else {
        return DefaultResponse(status: res.status, message: res.message);
      }
    } catch (e) {
      return DefaultResponse.withError(Error(message: e.toString()));
    }
  }

  Future<DefaultResponse<UserModel>> updateStaff(
    UpdateStaffRequestModel updateStaffRequestModel,
  ) async {
    try {
      final Map resJson = await _baseAPI.request(
        manager: ApiManager(ApiType.updateStaff),
        bodyParams: {
          "birthday": updateStaffRequestModel.birthday,
          "address": updateStaffRequestModel.address,
          "certification": updateStaffRequestModel.certification,
          "id_card": updateStaffRequestModel.idCard,
          "id_card_image_front": updateStaffRequestModel.idCardImageFront,
          "id_card_image_back": updateStaffRequestModel.idCardImageBack,
          "services": updateStaffRequestModel.services,
        },
      );
      final res = DefaultResponse.fromMap(resJson);
      if (res.status == 200 && res.data != null) {
        final item = UserModel.fromJson(res.data);
        return DefaultResponse(data: item);
      } else {
        return DefaultResponse(status: res.status, message: res.message);
      }
    } catch (e) {
      return DefaultResponse.withError(Error(message: e.toString()));
    }
  }

  Future<DefaultResponse<UserModel>> getUserInfo() async {
    try {
      final Map resJson = await _baseAPI.request(
        manager: ApiManager(ApiType.userInfo),
      );
      final res = DefaultResponse.fromJson(resJson);
      if ((res.status == 200 || res.status == 1) && res.data != null) {
        final item = UserModel.fromJson(res.data);
        return DefaultResponse(data: item, status: 200);
      } else {
        return DefaultResponse(status: res.status, message: res.message);
      }
    } catch (e) {
      return DefaultResponse.withError(Error(message: e.toString()));
    }
  }

  Future<DefaultResponse<List<ProductCategory>>> getProductCategory() async {
    try {
      final Map resJson = await _baseAPI.request(
        manager: ApiManager(ApiType.getListProductCategory),
      );
      final res = DefaultResponse.fromMap(resJson);
      if (res.status == 200 && res.data != null) {
        List<ProductCategory> list = [];
        for (final item in res.data ?? []) {
          final model = ProductCategory.fromJson(item);
          list.add(model);
        }
        return DefaultResponse(data: list);
      } else {
        return DefaultResponse(status: res.status, message: res.message);
      }
    } catch (e) {
      return DefaultResponse.withError(Error(message: e.toString()));
    }
  }

  Future<DefaultResponse<ProductCategory>> getProductCategoryDetail(
    int id,
  ) async {
    try {
      final Map resJson = await _baseAPI.request(
        manager: ApiManager(
          ApiType.getListProductCategory,
          additionalPath: '/$id',
        ),
      );
      final res = DefaultResponse.fromMap(resJson);
      if (res.status == 200 && res.data != null) {
        return DefaultResponse(data: ProductCategory.fromJson(res.data));
      } else {
        return DefaultResponse(status: res.status, message: res.message);
      }
    } catch (e) {
      return DefaultResponse.withError(Error(message: e.toString()));
    }
  }

  Future<DefaultResponse<List<ProductModel>>> getListProduct({
    required int isLike,
  }) async {
    try {
      final Map resJson = await _baseAPI.request(
        manager: ApiManager(ApiType.getProduct),
        queryParams: {"is_like": isLike},
      );
      final res = DefaultResponse.fromMap(resJson);
      if (res.status == 200 && res.data != null) {
        List<ProductModel> list = [];
        for (final item in res.data ?? []) {
          final model = ProductModel.fromJson(item);
          list.add(model);
        }
        return DefaultResponse(data: list);
      } else {
        return DefaultResponse(status: res.status, message: res.message);
      }
    } catch (e) {
      return DefaultResponse.withError(Error(message: e.toString()));
    }
  }

  Future<DefaultResponse<List<ProductModel>>> getProductsInUse() async {
    try {
      final Map resJson = await _baseAPI.request(
        manager: ApiManager(ApiType.getProduct),
        queryParams: {
          //"user_id": App.instance.userApp?.id,
          "user_id": 2,
        },
      );
      final res = DefaultResponse.fromMap(resJson);
      if (res.status == 200 && res.data != null) {
        List<ProductModel> list = [];
        for (final item in res.data ?? []) {
          final model = ProductModel.fromJson(item);
          list.add(model);
        }
        return DefaultResponse(data: list);
      } else {
        return DefaultResponse(status: res.status, message: res.message);
      }
    } catch (e) {
      return DefaultResponse.withError(Error(message: e.toString()));
    }
  }

  Future<DefaultResponse<ProductModel>> getProductDetail(
    ProductModel productModel,
  ) async {
    try {
      final Map resJson = await _baseAPI.request(
        manager: ApiManager(
          ApiType.getProduct,
          additionalPath: '/${productModel.id}',
        ),
      );
      final res = DefaultResponse.fromMap(resJson);
      if (res.status == 200 && res.data != null) {
        return DefaultResponse(data: ProductModel.fromJson(res.data));
      } else {
        return DefaultResponse(status: res.status, message: res.message);
      }
    } catch (e) {
      return DefaultResponse.withError(Error(message: e.toString()));
    }
  }

  Future<DefaultResponse<List<BlogModel>>> getBlogs({int page = 1}) async {
    try {
      final Map resJson = await _baseAPI.request(
        manager: ApiManager(ApiType.getBlogs),
        queryParams: {"page": page},
      );
      final res = DefaultResponse.fromMap(resJson);
      if ((res.status == 200 || res.status == 1) && res.data != null) {
        List<BlogModel> list = [];
        for (final item in res.data ?? []) {
          final model = BlogModel.fromJson(item);
          list.add(model);
        }
        return DefaultResponse(
          data: list,
          status: res.status,
          message: res.message,
        );
      } else {
        return DefaultResponse(status: res.status, message: res.message);
      }
    } catch (e) {
      return DefaultResponse.withError(Error(message: e.toString()));
    }
  }

  Future<DefaultResponse<List<BannerModel>>> getBanners() async {
    try {
      final Map resJson = await _baseAPI.request(
        manager: ApiManager(ApiType.getBanners),
      );
      final res = DefaultResponse.fromMap(resJson);
      if ((resJson['code'] == 1 || res.status == 200) && res.data != null) {
        List<BannerModel> list = [];
        if (res.data is List) {
          for (final item in res.data ?? []) {
            final model = BannerModel.fromJson(item);
            list.add(model);
          }
        } else if (res.data is Map) {
          final model = BannerModel.fromJson(
            Map<String, dynamic>.from(res.data as Map),
          );
          list.add(model);
        }
        return DefaultResponse(data: list, status: HttpStatus.ok);
      } else {
        return DefaultResponse(status: res.status, message: res.message);
      }
    } catch (e) {
      return DefaultResponse.withError(Error(message: e.toString()));
    }
  }

  Future<DefaultResponse> logout() async {
    try {
      final Map resJson = await _baseAPI.request(
        manager: ApiManager(ApiType.logout),
      );
      final res = DefaultResponse.fromMap(resJson);
      if (res.status == 200 && res.data != null) {
        return DefaultResponse();
      } else {
        return DefaultResponse(status: res.status, message: res.message);
      }
    } catch (e) {
      return DefaultResponse.withError(Error(message: e.toString()));
    }
  }

  Future<DefaultResponse<List<NotificationResponse>>> getNotifications() async {
    try {
      var dio = Dio();
      var response = await dio.get(
        AppConfig.instance.apiUrl(ApiEndpoints.notificationList),
        options: Options(contentType: 'application/json'),
      );
      var res = Map<String, dynamic>.from(jsonDecode(response.toString()));
      // final res = response.data;
      if (res["code"] != null && res["code"] == 1 && res["data"] != null) {
        var response = DefaultResponse(
          status: res["code"],
          data: List<NotificationResponse>.from(
            res["data"].map((model) => NotificationResponse.fromJson(model)),
          ),
        );
        return response;
      } else {
        return DefaultResponse(message: res["message"]);
      }
    } catch (e) {
      return DefaultResponse.withError(Error(message: e.toString()));
    }
  }

  Future<DefaultResponse<List<GiftResponse>>> getGiftsList({
    bool isReceiveList = false,
  }) async {
    try {
      final Map resJson = await _baseAPI.request(
        manager: ApiManager(
          ApiType.getGiftList,
          additionalPath: isReceiveList ? "/listReceive" : '',
        ),
      );
      final res = DefaultResponse.fromMap(resJson);
      if (res.status == 200 && res.data != null) {
        List<GiftResponse> list = [];
        for (final item in res.data ?? []) {
          final model = GiftResponse.fromJson(item);
          list.add(model);
        }
        return DefaultResponse(data: list);
      } else {
        return DefaultResponse(status: res.status, message: res.message);
      }
    } catch (e) {
      return DefaultResponse.withError(Error(message: e.toString()));
    }
  }

  Future<DefaultResponse<List<UserModel>>> getStaffs({int isLike = 0}) async {
    try {
      final Map resJson = await _baseAPI.request(
        manager: ApiManager(ApiType.getStaffs),
        queryParams: {"is_like": isLike},
      );
      final res = DefaultResponse.fromMap(resJson);
      if (res.status == 200 && res.data != null) {
        List<UserModel> list = [];
        for (final item in res.data ?? []) {
          final model = UserModel.fromJson(item);
          list.add(model);
        }
        return DefaultResponse(data: list);
      } else {
        return DefaultResponse(status: res.status, message: res.message);
      }
    } catch (e) {
      return DefaultResponse.withError(Error(message: e.toString()));
    }
  }

  Future<DefaultResponse> uploadImage({required File file}) async {
    try {
      final FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: path_manager.basename(file.path),
        ),
      });
      final Map resJson = await _baseAPI.request(
        manager: ApiManager(ApiType.uploadImage),
        bodyParams: formData,
      );
      final res = DefaultResponse.fromMap(resJson);
      if (res.status == 200 && res.data != null) {
        return DefaultResponse(data: res.data);
      } else {
        return DefaultResponse(status: res.status, message: res.message);
      }
    } catch (e) {
      return DefaultResponse.withError(Error(message: e.toString()));
    }
  }

  Future<DefaultResponse<UserModel>> updateUserInfo(
    UserInfoRequest userInfoRequest,
  ) async {
    try {
      Map<String, dynamic> bodyParams = {};
      bodyParams["username"] = userInfoRequest.username?.isNotEmpty == true
          ? userInfoRequest.username
          : (App.instance.userApp?.username ?? '');
      bodyParams["phone"] = userInfoRequest.phone?.isNotEmpty == true
          ? userInfoRequest.phone
          : (App.instance.userApp?.phone ?? '');
      bodyParams["avartar"] = userInfoRequest.avatar?.isNotEmpty == true
          ? userInfoRequest.avatar
          : (App.instance.userApp?.avatar ?? '');
      bodyParams["email"] = userInfoRequest.email?.isNotEmpty == true
          ? userInfoRequest.email
          : (App.instance.userApp?.email ?? '');
      bodyParams["address"] = userInfoRequest.address?.isNotEmpty == true
          ? userInfoRequest.address
          : (App.instance.userApp?.address ?? '');
      bodyParams["birthday"] = userInfoRequest.birthday?.isNotEmpty == true
          ? DateFormat(
              'yyyy/MM/dd',
            ).format(DateFormat('dd/MM/yyyy').parse(userInfoRequest.birthday!))
          : (App.instance.userApp?.birthday != null
                ? DateFormat('yyyy/MM/dd').format(
                    DateFormat(
                      'dd/MM/yyyy',
                    ).parse(App.instance.userApp!.birthday!),
                  )
                : '');
      bodyParams["cmt"] = userInfoRequest.cmt?.isNotEmpty == true
          ? userInfoRequest.cmt
          : (App.instance.userApp?.cmt ?? '');
      var url = AppConfig.instance.apiUri(ApiEndpoints.updateUser, bodyParams);
      var res = await http.post(url);
      if (res.statusCode == HttpStatus.ok) {
        var response = Map<String, dynamic>.from(json.decode(res.body));
        if (response["code"] == 1 && response["data"] != null) {
          return DefaultResponse(data: UserModel.fromJson(response["data"]));
        } else {
          return DefaultResponse(message: response["message"]);
        }
      } else {
        return DefaultResponse(message: "Update fail");
      }
    } catch (e) {
      return DefaultResponse.withError(Error(message: e.toString()));
    }
  }

  Future<DefaultResponse<UserModel>> changePassword(
    ChangePasswordRequest changePasswordRequest,
  ) async {
    try {
      var bodyParams = {
        "old_pass": changePasswordRequest.oldPassword,
        "new_password": changePasswordRequest.password,
        "new_password_confirm": changePasswordRequest.rePassword,
      };
      var url = AppConfig.instance.apiUri(
        ApiEndpoints.userChangePassword,
        bodyParams,
      );
      var res = await http.post(url);
      if (res.statusCode == HttpStatus.ok) {
        var response = Map<String, dynamic>.from(json.decode(res.body));
        if (response["status"] != null &&
            response["status"] == 1 &&
            response["data"] != null) {
          return DefaultResponse(data: UserModel.fromJson(response["data"]));
        } else {
          return DefaultResponse(
            status: response["status"],
            message: response["message"],
          );
        }
        // if (response["code"] == 1 && response["data"] != null) {
        //   return DefaultResponse(
        //       data: UserModel.fromJson(response["data"]));
        // } else {
        //   return DefaultResponse(message: response["message"]);
        // }
      } else {
        return DefaultResponse(message: "Update fail");
      }

      // var dio = Dio();
      // var response = await dio.post(
      //     AppConfig.instance.apiUrl("/user/${App.instance.userApp!.phone}/changePassWord"),
      //     data: bodyParams,
      //     options: Options(contentType: 'application/json'));
      // final res = response.data;
      // if (res["status"]!=null && res["status"] == 1 && res.data != null) {
      //   return DefaultResponse(data: UserModel.fromJson(res.data));
      // } else {
      //   return DefaultResponse(status: res.status, message: res.message);
      // }
    } catch (e) {
      return DefaultResponse.withError(Error(message: e.toString()));
    }
  }

  Future<DefaultResponse> forgotPassword(
    NewPasswordRequest newPasswordRequest,
  ) async {
    try {
      var dio = Dio();
      var response = await dio.post(
        AppConfig.instance.apiUrl(ApiEndpoints.forgotPassword),
        data: {
          "phone": newPasswordRequest.phone,
          "new_password": newPasswordRequest.newPassword,
          "new_password_confirm": newPasswordRequest.newPasswordConfirm,
        },
        options: Options(contentType: 'application/json'),
      );
      var res = Map<String, dynamic>.from(jsonDecode(response.toString()));
      // final res = response.data;
      if (res["code"] != null && res["code"] == 1 && res["data"] != null) {
        LoggerUtil.log("res.data ${res["data"]}");
        return DefaultResponse(data: res["data"]);
      } else {
        return DefaultResponse(message: res["message"]);
      }

      // final Map resJson = await _baseAPI.request(
      //     manager: ApiManager(ApiType.updateUserInfo),
      //     bodyParams: {
      //       "phone": newPasswordRequest.phone,
      //       "password": newPasswordRequest.newPassword,
      //       "password_confirmation": newPasswordRequest.newPasswordConfirm
      //     },
      //     isUseAccessToken: false);
      // LoggerUtil.log("resJson ${resJson.toString()}");
      //
      // final res = DefaultResponse.fromMap(resJson);
      // if (res.status == 200 && res.data != null) {
      //   LoggerUtil.log("res.data ${res.data}");
      //   return DefaultResponse(data: res.data);
      // } else {
      //   return DefaultResponse(status: res.status, message: res.message);
      // }
    } catch (e) {
      return DefaultResponse.withError(Error(message: e.toString()));
    }
  }

  Future<DefaultResponse<List<HomeServiceModel>>> getListService() async {
    try {
      final Map resJson = await _baseAPI.request(
        manager: ApiManager(ApiType.getServices),
      );
      final res = DefaultResponse.fromMap(resJson);
      if (res.status == 200 && res.data != null) {
        List<HomeServiceModel> list = [];
        for (final item in res.data ?? []) {
          final model = HomeServiceModel.fromJson(item);
          list.add(model);
        }
        return DefaultResponse(data: list);
      } else {
        return DefaultResponse(status: res.status, message: res.message);
      }
    } catch (e) {
      return DefaultResponse.withError(Error(message: e.toString()));
    }
  }

  Future<DefaultResponse> createTask(
    CreateTaskRequest createTaskRequest,
  ) async {
    try {
      final Map resJson = await _baseAPI.request(
        manager: ApiManager(ApiType.createTask),
        bodyParams: {
          "type": createTaskRequest.type,
          "name": createTaskRequest.name,
          "des": createTaskRequest.des,
          "status": createTaskRequest.status,
          "priority": createTaskRequest.priority,
          "serviceId": createTaskRequest.serviceId,
          "timeStart": createTaskRequest.timeStart,
          "timeEnd": createTaskRequest.timeEnd,
          "address": createTaskRequest.address,
          "lat": createTaskRequest.lat,
          "lng": createTaskRequest.lng,
          "staffId": createTaskRequest.staffId,
          "video": createTaskRequest.video,
          "images": createTaskRequest.images,
        },
      );
      final res = DefaultResponse.fromMap(resJson);
      if (res.status == 200 && res.data != null) {
        LoggerUtil.log("res.data ${res.data}");
        return DefaultResponse(data: res.data);
      } else {
        return DefaultResponse(status: res.status, message: res.message);
      }
    } catch (e) {
      return DefaultResponse.withError(Error(message: e.toString()));
    }
  }

  Future<DefaultResponse> likeProduct(int productId, bool isLike) async {
    try {
      final Map resJson = await _baseAPI.request(
        manager: ApiManager(ApiType.likeProduct),
        bodyParams: {"product_id": productId},
        optionalPath: "/${isLike ? "likeProduct" : "unlikeProduct"}",
      );
      final res = DefaultResponse.fromMap(resJson);
      if (res.status == 200 && res.data != null) {
        return DefaultResponse(data: res.data);
      } else {
        return DefaultResponse(status: res.status, message: res.message);
      }
    } catch (e) {
      return DefaultResponse.withError(Error(message: e.toString()));
    }
  }

  Future<DefaultResponse> exchangeGift(int giftId) async {
    try {
      final Map resJson = await _baseAPI.request(
        manager: ApiManager(ApiType.exchangeGift),
        bodyParams: {"gift_id": giftId},
      );
      final res = DefaultResponse.fromMap(resJson);
      if (res.status == 200 && res.data != null) {
        return DefaultResponse(data: res.data);
      } else {
        return DefaultResponse(status: res.status, message: res.message);
      }
    } catch (e) {
      return DefaultResponse.withError(Error(message: e.toString()));
    }
  }

  Future<DefaultResponse<List<UserModel>>> getListStaffByDistance(
    StaffByDistanceRequest staffByDistanceRequest,
  ) async {
    try {
      final Map resJson = await _baseAPI.request(
        manager: ApiManager(ApiType.staffByDistance),
        bodyParams: {
          "lat": staffByDistanceRequest.lat,
          "lng": staffByDistanceRequest.lng,
          "distance": staffByDistanceRequest.distance,
        },
      );
      final res = DefaultResponse.fromMap(resJson);
      if (res.status == 200 && res.data != null) {
        LoggerUtil.log("res.data ${res.data}");
        List<UserModel> list = [];
        for (final item in res.data ?? []) {
          final model = UserModel.fromJson(item);
          list.add(model);
        }
        return DefaultResponse(data: list);
      } else {
        return DefaultResponse(status: res.status, message: res.message);
      }
    } catch (e) {
      return DefaultResponse.withError(Error(message: e.toString()));
    }
  }

  Future<DefaultResponse<List<UserModel>>> getListSupporters() async {
    try {
      final Map resJson = await _baseAPI.request(
        manager: ApiManager(ApiType.getListSupporters),
      );
      final res = DefaultResponse.fromMap(resJson);
      if (res.status == 200 && res.data != null) {
        List<UserModel> list = [];
        for (final item in res.data ?? []) {
          final model = UserModel.fromJson(item);
          list.add(model);
        }
        return DefaultResponse(data: list);
      } else {
        return DefaultResponse(status: res.status, message: res.message);
      }
    } catch (e) {
      return DefaultResponse.withError(Error(message: e.toString()));
    }
  }

  Future<DefaultResponse> updateTask(
    int id,
    UpdateTaskRequest updateTaskRequest,
  ) async {
    try {
      final Map resJson = await _baseAPI.request(
        manager: ApiManager(ApiType.updateTask, additionalPath: '/$id'),
        bodyParams: {
          "type": updateTaskRequest.type,
          "name": updateTaskRequest.name,
          "des": updateTaskRequest.des,
          "status": updateTaskRequest.status,
          "priority": updateTaskRequest.priority,
          "service_id": updateTaskRequest.serviceId,
          "time_start": updateTaskRequest.timeStart,
          "time_end": updateTaskRequest.timeEnd,
          "staff_id": updateTaskRequest.staffId,
          "sale_id": updateTaskRequest.saleId,
          "customer_id": updateTaskRequest.customerId,
          "order_id": updateTaskRequest.orderId,
          "products": updateTaskRequest.products,
        },
      );
      final res = DefaultResponse.fromMap(resJson);
      if (res.status == 200 && res.data != null) {
        return DefaultResponse(data: res.data);
      } else {
        return DefaultResponse(status: res.status, message: res.message);
      }
    } catch (e) {
      return DefaultResponse.withError(Error(message: e.toString()));
    }
  }

  Future<DefaultResponse> likeStaff(int id) async {
    try {
      final Map resJson = await _baseAPI.request(
        manager: ApiManager(ApiType.likeStaff),
        bodyParams: {"staff_id": id},
      );
      final res = DefaultResponse.fromMap(resJson);
      if (res.status == 200 && res.data != null) {
        return DefaultResponse(data: res.data);
      } else {
        return DefaultResponse(status: res.status, message: res.message);
      }
    } catch (e) {
      return DefaultResponse.withError(Error(message: e.toString()));
    }
  }

  Future<DefaultResponse> unLikeStaff(int id) async {
    try {
      final Map resJson = await _baseAPI.request(
        manager: ApiManager(ApiType.unlikeStaff),
        bodyParams: {"staff_id": id},
      );
      final res = DefaultResponse.fromMap(resJson);
      if (res.status == 200 && res.data != null) {
        return DefaultResponse(data: res.data);
      } else {
        return DefaultResponse(status: res.status, message: res.message);
      }
    } catch (e) {
      return DefaultResponse.withError(Error(message: e.toString()));
    }
  }

  Future<DefaultResponse<List<UserAddress>>> getListUserAddress() async {
    try {
      final Map resJson = await _baseAPI.request(
        manager: ApiManager(ApiType.getListUserAddress),
      );
      final res = DefaultResponse.fromMap(resJson);
      if (res.status == 200 && res.data != null) {
        List<UserAddress> list = [];
        for (final item in res.data ?? []) {
          final model = UserAddress.fromJson(item);
          list.add(model);
        }
        return DefaultResponse(data: list);
      } else {
        return DefaultResponse(status: res.status, message: res.message);
      }
    } catch (e) {
      return DefaultResponse.withError(Error(message: e.toString()));
    }
  }

  Future<DefaultResponse> createUserAddress(
    UserAddressRequest userAddressRequest,
  ) async {
    try {
      var dio = Dio();
      var data = {
        "name": userAddressRequest.name,
        "phone": userAddressRequest.phone,
        "address": userAddressRequest.address,
        "type_staff": userAddressRequest.typeStaff ?? '0',
        "lat": userAddressRequest.lat,
        "lng": userAddressRequest.lng,
        "is_default": userAddressRequest.isDefault,
        "city_code": userAddressRequest.cityCode,
        "state_code": userAddressRequest.stateCode,
        "pass": userAddressRequest.pass,
      };

      if (userAddressRequest.typeStaff == "1") {
        data['type'] = '2';
        data['birthday'] = DateFormat(
          'yyyy/MM/dd',
        ).format(DateFormat('dd/MM/yyyy').parse(userAddressRequest.birthday!));
        // data['id_card_number'] = userAddressRequest.idCard;
        data['cmt'] = userAddressRequest.cmt;
        data['id_card_image_front'] = userAddressRequest.idCardImageFront;
        data['id_card_image_back'] = userAddressRequest.idCardImageBack;
        data['services'] = userAddressRequest.services;
      }

      var response = await dio.post(
        AppConfig.instance.apiUrl(ApiEndpoints.userRegister),
        data: data,
        options: Options(contentType: 'application/json'),
      );
      var res = Map<String, dynamic>.from(jsonDecode(response.toString()));
      print(res);
      if (res["code"] != null && res["code"] == 1 && res["data"] != null) {
        LoggerUtil.log("res.data ${res["data"]}");
        return DefaultResponse(status: res["code"], data: res["data"]);
      } else {
        return DefaultResponse(status: res["code"], message: res["message"]);
      }
    } catch (e) {
      return DefaultResponse.withError(Error(message: e.toString()));
    }
  }

  Future<DefaultResponse> updateUserAddress(
    UserAddressRequest userAddressRequest,
  ) async {
    try {
      final Map resJson = await _baseAPI.request(
        manager: ApiManager(ApiType.updateUserAddress),
        bodyParams: {
          "name": userAddressRequest.name,
          "phone": userAddressRequest.phone,
          "address": userAddressRequest.address,
          "lat": userAddressRequest.lat,
          "lng": userAddressRequest.lng,
          "is_default": userAddressRequest.isDefault,
          "city_code": userAddressRequest.cityCode,
          "state_code": userAddressRequest.stateCode,
        },
        optionalPath: "/${userAddressRequest.id}",
      );
      final res = DefaultResponse.fromMap(resJson);
      if (res.status == 200 && res.data != null) {
        return DefaultResponse(data: res.data);
      } else {
        return DefaultResponse(status: res.status, message: res.message);
      }
    } catch (e) {
      return DefaultResponse.withError(Error(message: e.toString()));
    }
  }

  Future<DefaultResponse> deleteUserAddress(String id) async {
    try {
      final Map resJson = await _baseAPI.request(
        manager: ApiManager(ApiType.deleteUserAddress),
        optionalPath: "/$id",
      );
      final res = DefaultResponse.fromMap(resJson);
      if (res.status == 200 && res.data != null) {
        return DefaultResponse(data: res.data);
      } else {
        return DefaultResponse(status: res.status, message: res.message);
      }
    } catch (e) {
      return DefaultResponse.withError(Error(message: e.toString()));
    }
  }

  Future<DefaultResponse<List<TaskModel>>> getListTask({
    required int page,
  }) async {
    try {
      final Map resJson = await _baseAPI.request(
        manager: ApiManager(ApiType.getListTask),
        queryParams: {"page": page},
      );
      final res = DefaultResponse.fromMap(resJson);
      if (res.status == 200 && res.data != null) {
        List<TaskModel> list = [];
        for (final item in res.data ?? []) {
          final model = TaskModel.fromJson(item);
          list.add(model);
        }
        return DefaultResponse(data: list);
      } else {
        return DefaultResponse(status: res.status, message: res.message);
      }
    } catch (e) {
      return DefaultResponse.withError(Error(message: e.toString()));
    }
  }

  Future<DefaultResponse<TaskModel>> getTask(int id) async {
    try {
      final Map resJson = await _baseAPI.request(
        manager: ApiManager(ApiType.getTask),
        optionalPath: '/$id',
      );
      final res = DefaultResponse.fromMap(resJson);
      if (res.status == 200 && res.data != null) {
        return DefaultResponse(data: TaskModel.fromJson(res.data));
      } else {
        return DefaultResponse(status: res.status, message: res.message);
      }
    } catch (e) {
      return DefaultResponse.withError(Error(message: e.toString()));
    }
  }

  Future<DefaultResponse> deleteTask(int id, String name, String des) async {
    try {
      final Map resJson = await _baseAPI.request(
        manager: ApiManager(ApiType.deleteTask),
        bodyParams: {'name': name, 'description': des},
        optionalPath: '/$id',
      );
      final res = DefaultResponse.fromMap(resJson);
      if (res.status == 200 && res.data != null) {
        return DefaultResponse(data: res.data);
      } else {
        return DefaultResponse(status: res.status, message: res.message);
      }
    } catch (e) {
      return DefaultResponse.withError(Error(message: e.toString()));
    }
  }

  Future<DefaultResponse> storeAssignmentImage({
    required String id,
    required String note,
    required File image,
  }) async {
    try {
      final String url = AppConfig.instance.apiUrl(
        ApiEndpoints.retailOrderShipConfirm(id),
      );

      final request = http.MultipartRequest('POST', Uri.parse(url));

      // Add fields matching the other working app
      request.fields['note'] = note;
      request.fields['retail_shipment_assigment_user_id'] = id;
      request.fields['image'] = image
          .toString(); // Exact string mapping of File

      // Add actual image file stream
      final stream = http.ByteStream(image.openRead());
      final length = await image.length();
      final filename = image.path.split('/').last;

      final multipartFile = http.MultipartFile(
        'image',
        stream,
        length,
        filename: filename,
      );
      request.files.add(multipartFile);

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      final Map resJson = json.decode(response.body);
      final res = DefaultResponse.fromJson(Map<String, dynamic>.from(resJson));
      return res;
    } catch (e) {
      return DefaultResponse.withError(Error(message: e.toString()));
    }
  }

  Future<DefaultResponse<UserProfile>> getKPIs(String userId) async {
    try {
      final Map resJson = await _baseAPI.request(
        manager: ApiManager(ApiType.getKPIByUser, additionalPath: userId),
      );
      final res = DefaultResponse.fromJson(Map<String, dynamic>.from(resJson));
      if (res.status == 200 || res.status == 1) {
        final baseProfile = App.instance.userApp?.userProfile;

        final kpiData = resJson['data'] != null
            ? KPIDataResponse.fromJson(
                Map<String, dynamic>.from(resJson['data']),
              )
            : null;

        final attendances = resJson['data_attendances'] != null
            ? userAttendancesListFromJson(resJson['data_attendances'])
            : null;

        final parsed = UserProfile(
          id: baseProfile?.id,
          userId: baseProfile?.userId ?? userId,
          bankInfo: baseProfile?.bankInfo,
          bankQr: baseProfile?.bankQr,
          basicSalary: baseProfile?.basicSalary,
          bhxh: baseProfile?.bhxh,
          totalIncome: baseProfile?.totalIncome,
          typeStaff: baseProfile?.typeStaff,
          typeContract: baseProfile?.typeContract,
          infoContract: baseProfile?.infoContract,
          monthContract: baseProfile?.monthContract,
          level: baseProfile?.level,
          description: baseProfile?.description,
          dayOff: baseProfile?.dayOff,
          user: baseProfile?.user ?? App.instance.userApp,
          kpi: kpiData,
          userAttendances: attendances,
        );
        return DefaultResponse(
          data: parsed,
          status: res.status,
          message: res.message,
        );
      } else {
        return DefaultResponse(status: res.status, message: res.message);
      }
    } catch (e) {
      return DefaultResponse.withError(Error(message: e.toString()));
    }
  }

  Future<DefaultResponse<WalletModel>> getWalletBalance() async {
    try {
      final Map resJson = await _baseAPI.request(
        manager: ApiManager(ApiType.getWallet),
      );
      final res = DefaultResponse.fromJson(Map<String, dynamic>.from(resJson));
      if ((res.status == 200 || res.status == 1) && resJson['data'] != null) {
        final walletData = resJson['data']['wallet'];
        return DefaultResponse(
          status: res.status,
          message: res.message,
          data: walletData != null
              ? WalletModel.fromJson(Map<String, dynamic>.from(walletData))
              : WalletModel(),
        );
      } else {
        return DefaultResponse(status: res.status, message: res.message);
      }
    } catch (e) {
      return DefaultResponse.withError(Error(message: e.toString()));
    }
  }

  Future<DefaultResponse<List<WalletTransactionModel>>> getWalletTransactions({
    int? limit,
  }) async {
    try {
      final Map resJson = await _baseAPI.request(
        manager: ApiManager(ApiType.getWalletTransactions),
        queryParams: limit != null ? {'limit': limit.toString()} : null,
      );
      final res = DefaultResponse.fromJson(Map<String, dynamic>.from(resJson));
      if ((res.status == 200 || res.status == 1) && resJson['data'] != null) {
        final listData = resJson['data']['data'];
        final list = listData is List
            ? listData
                  .map(
                    (item) => WalletTransactionModel.fromJson(
                      Map<String, dynamic>.from(item),
                    ),
                  )
                  .toList()
            : <WalletTransactionModel>[];
        return DefaultResponse(
          status: res.status,
          message: res.message,
          data: list,
        );
      } else {
        return DefaultResponse(status: res.status, message: res.message);
      }
    } catch (e) {
      return DefaultResponse.withError(Error(message: e.toString()));
    }
  }

  Future<DefaultResponse> requestWalletAdvance({
    required double amount,
    int? orderId,
    String? note,
    List<File>? proofImages,
  }) async {
    try {
      final Map<String, dynamic> dataMap = {'amount': amount.toString()};
      if (orderId != null) {
        dataMap['order_id'] = orderId.toString();
      }
      if (note != null) {
        dataMap['note'] = note;
      }
      if (proofImages != null && proofImages.isNotEmpty) {
        final List<MultipartFile> files = [];
        for (var image in proofImages) {
          files.add(
            await MultipartFile.fromFile(
              image.path,
              filename: path_manager.basename(image.path),
            ),
          );
        }
        dataMap['proof_images[]'] = files;
      }

      final FormData formData = FormData.fromMap(dataMap);
      final Map resJson = await _baseAPI.request(
        manager: ApiManager(ApiType.walletAdvance),
        bodyParams: formData,
      );
      return DefaultResponse.fromJson(Map<String, dynamic>.from(resJson));
    } catch (e) {
      return DefaultResponse.withError(Error(message: e.toString()));
    }
  }

  Future<DefaultResponse> requestWalletDeposit({
    required double amount,
    String? note,
    List<File>? proofImages,
  }) async {
    try {
      final Map<String, dynamic> dataMap = {'amount': amount.toString()};
      if (note != null) {
        dataMap['note'] = note;
      }
      if (proofImages != null && proofImages.isNotEmpty) {
        final List<MultipartFile> files = [];
        for (var image in proofImages) {
          files.add(
            await MultipartFile.fromFile(
              image.path,
              filename: path_manager.basename(image.path),
            ),
          );
        }
        dataMap['proof_images[]'] = files;
      }

      final FormData formData = FormData.fromMap(dataMap);
      final Map resJson = await _baseAPI.request(
        manager: ApiManager(ApiType.walletDeposit),
        bodyParams: formData,
      );
      return DefaultResponse.fromJson(Map<String, dynamic>.from(resJson));
    } catch (e) {
      return DefaultResponse.withError(Error(message: e.toString()));
    }
  }
}
