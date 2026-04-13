import 'package:socbay/application.dart';

enum HttpMethod { get, post, put, del }

enum ApiType {
  /// AUTH
  setOtp,
  login,
  register,
  logout,
  userInfo,

  ///HOME
  getBlogs,
  getBanners,
  getProduct,
  createFeedback,
  getServices,

  ///PRODUCT
  getListProductCategory,
  likeProduct,

  ///User
  getNotifications,
  getGiftList,
  getStaffs,
  updateUserInfo,
  updateStaff,
  changePassword,
  forgotPassword,
  exchangeGift,
  staffByDistance,
  getListSupporters,
  likeStaff,
  unlikeStaff,
  getListUserAddress,
  createUserAddress,
  updateUserAddress,
  deleteUserAddress,

  ///Staff

  ///MEDIA
  uploadImage,

  ///SERVICE
  createTask,
  updateTask,
  getListTask,
  getTask,
  deleteTask,
}

class ApiConfig {
  String path;
  HttpMethod method;
  Map<String, String> headers;

  ApiConfig({
    required this.path,
    required this.method,
    required this.headers,
  });
}

class ApiManager {
  final ApiType type;
  final String additionalPath;

  ApiManager(
    this.type, {
    this.additionalPath = "",
  });

  ApiConfig getConfig() {
    switch (type) {
      case ApiType.setOtp:
        return ApiConfig(
            path: '/auth/setOTP',
            method: HttpMethod.post,
            headers: _defaultHeaders);
      case ApiType.login:
        return ApiConfig(
            path: '/user/login',
            method: HttpMethod.post,
            headers: _defaultHeaders);
      case ApiType.register:
        return ApiConfig(
            path: '/auth/register',
            method: HttpMethod.post,
            headers: _defaultHeaders);
      case ApiType.logout:
        return ApiConfig(
            path: '/auth/logout',
            method: HttpMethod.post,
            headers: _defaultHeaders);
      case ApiType.updateStaff:
        return ApiConfig(
            path: '/user/update-staff',
            method: HttpMethod.post,
            headers: _defaultHeaders);
      case ApiType.userInfo:
        return ApiConfig(
            path: '/auth',
            method: HttpMethod.get,
            headers: _defaultHeaders);
      case ApiType.getListProductCategory:
        return ApiConfig(
            path: '/product-category$additionalPath',
            method: HttpMethod.get,
            headers: _defaultHeaders);
      case ApiType.getProduct:
        return ApiConfig(
            path: '/product$additionalPath',
            method: HttpMethod.get,
            headers: _defaultHeaders);
      case ApiType.getBlogs:
        return ApiConfig(
          path: '/blog/list',
          method: HttpMethod.get,
          headers: _defaultHeaders,
        );
      case ApiType.getBanners:
        return ApiConfig(
          path: '/banner',
          method: HttpMethod.get,
          headers: _defaultHeaders,
        );
      case ApiType.getNotifications:
        return ApiConfig(
          path: '/notify',
          method: HttpMethod.get,
          headers: _defaultHeaders,
        );
      case ApiType.getGiftList:
        return ApiConfig(
          path: '/gift$additionalPath',
          method: HttpMethod.get,
          headers: _defaultHeaders,
        );
      case ApiType.getStaffs:
        return ApiConfig(
          path: '/user/listStaff',
          method: HttpMethod.get,
          headers: _defaultHeaders,
        );
      case ApiType.updateUserInfo:
        return ApiConfig(
          path: '/user/updateUser',
          method: HttpMethod.post,
          headers: _defaultHeaders,
        );
      case ApiType.uploadImage:
        return ApiConfig(
          path: '/uploadImage',
          method: HttpMethod.post,
          headers: _defaultHeaders,
        );
      case ApiType.changePassword:
        return ApiConfig(
          path: '/user/${App.instance.userApp!.phone}/changePassWord',
          method: HttpMethod.post,
          headers: _defaultHeaders,
        );
      case ApiType.forgotPassword:
        return ApiConfig(
          path: '/auth/fogotPassWord',
          method: HttpMethod.post,
          headers: _defaultHeaders,
        );
      case ApiType.createFeedback:
        return ApiConfig(
            path: '/feedback',
            method: HttpMethod.post,
            headers: _defaultHeaders);
      case ApiType.getServices:
        return ApiConfig(
            path: '/service',
            method: HttpMethod.get,
            headers: _defaultHeaders);
      case ApiType.createTask:
        return ApiConfig(
            path: '/task',
            method: HttpMethod.post,
            headers: _defaultHeaders);
      case ApiType.likeProduct:
        return ApiConfig(
            path: '',
            method: HttpMethod.post,
            headers: _defaultHeaders);
      case ApiType.exchangeGift:
        return ApiConfig(
            path: '/gift/receive',
            method: HttpMethod.post,
            headers: _defaultHeaders);
      case ApiType.staffByDistance:
        return ApiConfig(
          path: '/user/nearest',
          method: HttpMethod.post,
          headers: _defaultHeaders,
        );
      case ApiType.getListSupporters:
        return ApiConfig(
            path: '/user/listSupporters',
            method: HttpMethod.get,
            headers: _defaultHeaders);
      case ApiType.updateTask:
        return ApiConfig(
            path: '/admin/task$additionalPath',
            method: HttpMethod.put,
            headers: _defaultHeaders);
      case ApiType.likeStaff:
        return ApiConfig(
            path: '/user/likeStaff',
            method: HttpMethod.post,
            headers: _defaultHeaders);
      case ApiType.unlikeStaff:
        return ApiConfig(
            path: '/user/unlikeStaff',
            method: HttpMethod.post,
            headers: _defaultHeaders);
      case ApiType.getListUserAddress:
        return ApiConfig(
            path: '/userAddress',
            method: HttpMethod.get,
            headers: _defaultHeaders);
      case ApiType.createUserAddress:
        return ApiConfig(
            path: '/user/register',
            method: HttpMethod.post,
            headers: _defaultHeaders);
      case ApiType.updateUserAddress:
        return ApiConfig(
            path: '/userAddress',
            method: HttpMethod.put,
            headers: _defaultHeaders);
      case ApiType.deleteUserAddress:
        return ApiConfig(
            path: '/userAddress',
            method: HttpMethod.del,
            headers: _defaultHeaders);
      case ApiType.getListTask:
        return ApiConfig(
            path: '/task',
            method: HttpMethod.get,
            headers: _defaultHeaders);
      case ApiType.getTask:
        return ApiConfig(
            path: '/task$additionalPath',
            method: HttpMethod.get,
            headers: _defaultHeaders);
      case ApiType.deleteTask:
        return ApiConfig(
            path: '/admin/task$additionalPath',
            method: HttpMethod.del,
            headers: _defaultHeaders);
    }
  }

  Map<String, String> get _defaultHeaders {
    return {
      'Content-Type': 'application/json',
    };
  }
}
