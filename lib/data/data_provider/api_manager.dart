import 'package:socbay/data/data_provider/api_endpoints.dart';

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
  storeAssignmentImage,

  ///SERVICE
  createTask,
  updateTask,
  getListTask,
  getTask,
  deleteTask,
  getKPIByUser,
  getWallet,
  getWalletTransactions,
  walletAdvance,
  walletDeposit,
  deleteTransaction,
}

class ApiConfig {
  String path;
  HttpMethod method;
  Map<String, String> headers;

  ApiConfig({required this.path, required this.method, required this.headers});
}

class ApiManager {
  final ApiType type;
  final String additionalPath;

  ApiManager(this.type, {this.additionalPath = ""});

  ApiConfig getConfig() {
    switch (type) {
      case ApiType.setOtp:
        return ApiConfig(
          path: ApiEndpoints.setOtp,
          method: HttpMethod.post,
          headers: _defaultHeaders,
        );
      case ApiType.login:
        return ApiConfig(
          path: ApiEndpoints.login,
          method: HttpMethod.post,
          headers: _defaultHeaders,
        );
      case ApiType.register:
        return ApiConfig(
          path: ApiEndpoints.register,
          method: HttpMethod.post,
          headers: _defaultHeaders,
        );
      case ApiType.logout:
        return ApiConfig(
          path: ApiEndpoints.logout,
          method: HttpMethod.post,
          headers: _defaultHeaders,
        );
      case ApiType.updateStaff:
        return ApiConfig(
          path: ApiEndpoints.updateStaff,
          method: HttpMethod.post,
          headers: _defaultHeaders,
        );
      case ApiType.userInfo:
        return ApiConfig(
          path: ApiEndpoints.userInfo,
          method: HttpMethod.get,
          headers: _defaultHeaders,
        );
      case ApiType.getListProductCategory:
        return ApiConfig(
          path: '${ApiEndpoints.productCategory}$additionalPath',
          method: HttpMethod.get,
          headers: _defaultHeaders,
        );
      case ApiType.getProduct:
        return ApiConfig(
          path: '${ApiEndpoints.products}$additionalPath',
          method: HttpMethod.get,
          headers: _defaultHeaders,
        );
      case ApiType.getBlogs:
        return ApiConfig(
          path: ApiEndpoints.blogs,
          method: HttpMethod.get,
          headers: _defaultHeaders,
        );
      case ApiType.getBanners:
        return ApiConfig(
          path: ApiEndpoints.banners,
          method: HttpMethod.get,
          headers: _defaultHeaders,
        );
      case ApiType.getNotifications:
        return ApiConfig(
          path: ApiEndpoints.notifications,
          method: HttpMethod.get,
          headers: _defaultHeaders,
        );
      case ApiType.getGiftList:
        return ApiConfig(
          path: '${ApiEndpoints.gifts}$additionalPath',
          method: HttpMethod.get,
          headers: _defaultHeaders,
        );
      case ApiType.getStaffs:
        return ApiConfig(
          path: ApiEndpoints.userListStaff,
          method: HttpMethod.get,
          headers: _defaultHeaders,
        );
      case ApiType.updateUserInfo:
        return ApiConfig(
          path: ApiEndpoints.updateUser,
          method: HttpMethod.post,
          headers: _defaultHeaders,
        );
      case ApiType.uploadImage:
        return ApiConfig(
          path: ApiEndpoints.uploadImage,
          method: HttpMethod.post,
          headers: _defaultHeaders,
        );
      case ApiType.storeAssignmentImage:
        return ApiConfig(
          path: ApiEndpoints.retailOrderShipConfirm(additionalPath),
          method: HttpMethod.post,
          headers: _defaultHeaders,
        );
      case ApiType.changePassword:
        return ApiConfig(
          path: ApiEndpoints.userChangePassword,
          method: HttpMethod.post,
          headers: _defaultHeaders,
        );
      case ApiType.forgotPassword:
        return ApiConfig(
          path: ApiEndpoints.forgotPassword,
          method: HttpMethod.post,
          headers: _defaultHeaders,
        );
      case ApiType.createFeedback:
        return ApiConfig(
          path: ApiEndpoints.feedbacks,
          method: HttpMethod.post,
          headers: _defaultHeaders,
        );
      case ApiType.getServices:
        return ApiConfig(
          path: ApiEndpoints.services,
          method: HttpMethod.get,
          headers: _defaultHeaders,
        );
      case ApiType.createTask:
        return ApiConfig(
          path: ApiEndpoints.tasks,
          method: HttpMethod.post,
          headers: _defaultHeaders,
        );
      case ApiType.likeProduct:
        return ApiConfig(
          path: '',
          method: HttpMethod.post,
          headers: _defaultHeaders,
        );
      case ApiType.exchangeGift:
        return ApiConfig(
          path: ApiEndpoints.giftReceive,
          method: HttpMethod.post,
          headers: _defaultHeaders,
        );
      case ApiType.staffByDistance:
        return ApiConfig(
          path: ApiEndpoints.userNearest,
          method: HttpMethod.post,
          headers: _defaultHeaders,
        );
      case ApiType.getListSupporters:
        return ApiConfig(
          path: ApiEndpoints.userListSupporters,
          method: HttpMethod.get,
          headers: _defaultHeaders,
        );
      case ApiType.updateTask:
        return ApiConfig(
          path: '${ApiEndpoints.taskEdit}$additionalPath',
          method: HttpMethod.post,
          headers: _defaultHeaders,
        );
      case ApiType.likeStaff:
        return ApiConfig(
          path: ApiEndpoints.userLikeStaff,
          method: HttpMethod.post,
          headers: _defaultHeaders,
        );
      case ApiType.unlikeStaff:
        return ApiConfig(
          path: ApiEndpoints.userUnlikeStaff,
          method: HttpMethod.post,
          headers: _defaultHeaders,
        );
      case ApiType.getListUserAddress:
        return ApiConfig(
          path: ApiEndpoints.userAddress,
          method: HttpMethod.get,
          headers: _defaultHeaders,
        );
      case ApiType.createUserAddress:
        return ApiConfig(
          path: ApiEndpoints.userRegister,
          method: HttpMethod.post,
          headers: _defaultHeaders,
        );
      case ApiType.updateUserAddress:
        return ApiConfig(
          path: ApiEndpoints.userAddress,
          method: HttpMethod.put,
          headers: _defaultHeaders,
        );
      case ApiType.deleteUserAddress:
        return ApiConfig(
          path: ApiEndpoints.userAddress,
          method: HttpMethod.del,
          headers: _defaultHeaders,
        );
      case ApiType.getListTask:
        return ApiConfig(
          path: ApiEndpoints.tasks,
          method: HttpMethod.get,
          headers: _defaultHeaders,
        );
      case ApiType.getTask:
        return ApiConfig(
          path: '${ApiEndpoints.tasks}$additionalPath',
          method: HttpMethod.get,
          headers: _defaultHeaders,
        );
      case ApiType.deleteTask:
        return ApiConfig(
          path: '${ApiEndpoints.taskDelete}$additionalPath',
          method: HttpMethod.del,
          headers: _defaultHeaders,
        );
      case ApiType.getKPIByUser:
        return ApiConfig(
          path: ApiEndpoints.kpiByUser(additionalPath),
          method: HttpMethod.get,
          headers: _defaultHeaders,
        );
      case ApiType.getWallet:
        return ApiConfig(
          path: ApiEndpoints.wallet,
          method: HttpMethod.get,
          headers: _defaultHeaders,
        );
      case ApiType.getWalletTransactions:
        return ApiConfig(
          path: ApiEndpoints.walletTransactions,
          method: HttpMethod.get,
          headers: _defaultHeaders,
        );
      case ApiType.walletAdvance:
        return ApiConfig(
          path: ApiEndpoints.walletAdvance,
          method: HttpMethod.post,
          headers: _defaultHeaders,
        );
      case ApiType.walletDeposit:
        return ApiConfig(
          path: ApiEndpoints.walletDeposit,
          method: HttpMethod.post,
          headers: _defaultHeaders,
        );
      case ApiType.deleteTransaction:
        return ApiConfig(
          path: ApiEndpoints.deleteTransactions(additionalPath),
          method: HttpMethod.del,
          headers: _defaultHeaders,
        );
    }
  }

  Map<String, String> get _defaultHeaders {
    return {'Content-Type': 'application/json', 'Accept': 'application/json'};
  }
}
