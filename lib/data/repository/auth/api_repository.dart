import 'dart:io';

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
import 'package:socbay/data/model/user_profile.dart';
import 'package:socbay/data/model/wallet_model.dart';
import 'package:socbay/data/provider/api_provider.dart';
import 'package:socbay/data/repository/auth/base_api_repository.dart';
import 'package:socbay/data/response/api_response.dart';

class ApiRepository extends BaseApiRepository {
  late ApiProvider _apiProvider;

  ApiRepository(BaseAPI baseAPI) {
    _apiProvider = ApiProvider(baseAPI);
  }

  @override
  Future<DefaultResponse> forgotPassword(
    NewPasswordRequest newPasswordRequest,
  ) {
    return _apiProvider.forgotPassword(newPasswordRequest);
  }

  @override
  Future<DefaultResponse> checkOTP(String phoneNumber, int otp) {
    throw UnimplementedError();
  }

  @override
  Future<DefaultResponse<LoginResponse>> loginAccount(
    String phone,
    String password, [
    String? fcmToken,
  ]) {
    return _apiProvider.login(phone, password, fcmToken);
  }

  @override
  Future<DefaultResponse> registerAccount(UserModel param) {
    throw UnimplementedError();
  }

  @override
  Future<DefaultResponse> setOTP(String phoneNumber) {
    return _apiProvider.setOTP(phoneNumber);
  }

  @override
  Future<DefaultResponse<UserModel>> getUserInfo() {
    return _apiProvider.getUserInfo();
  }

  @override
  Future<DefaultResponse<List<ProductCategory>>> getProductCategory() {
    return _apiProvider.getProductCategory();
  }

  @override
  Future<DefaultResponse<ProductCategory>> getProductCategoryDetail(int id) {
    return _apiProvider.getProductCategoryDetail(id);
  }

  @override
  Future<DefaultResponse<List<BlogModel>>> getBlogs({int page = 1}) {
    return _apiProvider.getBlogs(page: page);
  }

  @override
  Future<DefaultResponse<List<ProductModel>>> getProducts({int isLike = 0}) {
    return _apiProvider.getListProduct(isLike: isLike);
  }

  @override
  Future<DefaultResponse<List<ProductModel>>> getProductsInUse() {
    return _apiProvider.getProductsInUse();
  }

  @override
  Future<DefaultResponse<ProductModel>> getProductDetail({
    required ProductModel product,
  }) {
    return _apiProvider.getProductDetail(product);
  }

  @override
  Future<DefaultResponse<List<BannerModel>>> getBanners() {
    return _apiProvider.getBanners();
  }

  @override
  Future<DefaultResponse> logout() {
    return _apiProvider.logout();
  }

  @override
  Future<DefaultResponse<List<NotificationResponse>>> getNotifications() {
    try {
      return _apiProvider.getNotifications();
    } catch (e) {
      return _apiProvider.getNotifications();
    }
  }

  @override
  Future<DefaultResponse<List<GiftResponse>>> getGiftList({
    bool isReceive = false,
  }) {
    return _apiProvider.getGiftsList(isReceiveList: isReceive);
  }

  @override
  Future<DefaultResponse<List<UserModel>>> getStaffs({int isLike = 0}) {
    return _apiProvider.getStaffs(isLike: isLike);
  }

  @override
  Future<DefaultResponse> register(RegisterRequestModel registerRequestModel) {
    return _apiProvider.register(registerRequestModel);
  }

  @override
  Future<DefaultResponse> uploadFile({required File file}) =>
      _apiProvider.uploadImage(file: file);

  @override
  Future<DefaultResponse<UserModel>> updateUserInfo(
    UserInfoRequest userInfoRequest,
  ) => _apiProvider.updateUserInfo(userInfoRequest);

  @override
  Future<DefaultResponse<UserModel>> updateStaff(
    UpdateStaffRequestModel updateStaffRequestModel,
  ) => _apiProvider.updateStaff(updateStaffRequestModel);

  @override
  Future<DefaultResponse<UserModel>> changePassword(
    ChangePasswordRequest changePasswordRequest,
  ) {
    return _apiProvider.changePassword(changePasswordRequest);
  }

  @override
  Future<DefaultResponse<List<HomeServiceModel>>> getServices() {
    return _apiProvider.getListService();
  }

  @override
  Future<DefaultResponse> createTask(CreateTaskRequest createTaskRequest) {
    return _apiProvider.createTask(createTaskRequest);
  }

  @override
  Future<DefaultResponse> exchangeGift(int giftId) {
    return _apiProvider.exchangeGift(giftId);
  }

  @override
  Future<DefaultResponse> likeProduct({
    required int productId,
    required bool isLike,
  }) {
    return _apiProvider.likeProduct(productId, isLike);
  }

  @override
  Future<DefaultResponse<List<UserModel>>> getListStaffByDistance(
    StaffByDistanceRequest staffByDistanceRequest,
  ) {
    return _apiProvider.getListStaffByDistance(staffByDistanceRequest);
  }

  @override
  Future<DefaultResponse<List<UserModel>>> getListSupporters() {
    return _apiProvider.getListSupporters();
  }

  @override
  Future<DefaultResponse> updateTask(
    int id,
    UpdateTaskRequest updateTaskRequest,
  ) {
    return _apiProvider.updateTask(id, updateTaskRequest);
  }

  @override
  Future<DefaultResponse> likeStaff(int id) {
    return _apiProvider.likeStaff(id);
  }

  @override
  Future<DefaultResponse> unlikeStaff(int id) {
    return _apiProvider.unLikeStaff(id);
  }

  @override
  Future<DefaultResponse<List<UserAddress>>> getListUserAddress() {
    return _apiProvider.getListUserAddress();
  }

  @override
  Future<DefaultResponse> createUserAddress(
    UserAddressRequest userAddressRequest,
  ) {
    return _apiProvider.createUserAddress(userAddressRequest);
  }

  @override
  Future<DefaultResponse> updateUserAddress(
    UserAddressRequest userAddressRequest,
  ) {
    return _apiProvider.updateUserAddress(userAddressRequest);
  }

  @override
  Future<DefaultResponse> deleteUserAddress(String id) {
    return _apiProvider.deleteUserAddress(id);
  }

  @override
  Future<DefaultResponse<List<TaskModel>>> getListTask({int page = 1}) {
    return _apiProvider.getListTask(page: page);
  }

  @override
  Future<DefaultResponse<TaskModel>> getTask(int id) {
    return _apiProvider.getTask(id);
  }

  @override
  Future<DefaultResponse> deleteTask(int id, String name, String des) {
    return _apiProvider.deleteTask(id, name, des);
  }

  @override
  Future<DefaultResponse> storeAssignmentImage({
    required String id,
    required String note,
    required File image,
  }) {
    return _apiProvider.storeAssignmentImage(id: id, note: note, image: image);
  }

  @override
  Future<DefaultResponse<UserProfile>> getKPIs(String userId) {
    return _apiProvider.getKPIs(userId);
  }

  @override
  Future<DefaultResponse<WalletModel>> getWalletBalance() {
    return _apiProvider.getWalletBalance();
  }

  @override
  Future<DefaultResponse<List<WalletTransactionModel>>> getWalletTransactions({
    int? limit,
  }) {
    return _apiProvider.getWalletTransactions(limit: limit);
  }

  @override
  Future<DefaultResponse> requestWalletAdvance({
    required double amount,
    int? orderId,
    String? note,
    List<File>? proofImages,
  }) {
    return _apiProvider.requestWalletAdvance(
      amount: amount,
      orderId: orderId,
      note: note,
      proofImages: proofImages,
    );
  }

  @override
  Future<DefaultResponse> requestWalletDeposit({
    required double amount,
    String? note,
    List<File>? proofImages,
  }) {
    return _apiProvider.requestWalletDeposit(
      amount: amount,
      note: note,
      proofImages: proofImages,
    );
  }
}
