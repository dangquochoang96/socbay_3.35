import 'dart:io';

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
import 'package:socbay/data/response/api_response.dart';

abstract class BaseApiRepository {
  ///AUTH
  Future<DefaultResponse> setOTP(String phoneNumber);
  Future<DefaultResponse> checkOTP(String phoneNumber, int otp);
  Future<DefaultResponse> registerAccount(UserModel param);
  Future<DefaultResponse<LoginResponse>> loginAccount(
    String phone,
    String password, [
    String? fcmToken,
  ]);
  Future<DefaultResponse> register(RegisterRequestModel registerRequestModel);
  Future<DefaultResponse> forgotPassword(NewPasswordRequest newPasswordRequest);
  Future<DefaultResponse<UserModel>> getUserInfo();
  Future<DefaultResponse> logout();

  ///USER
  Future<DefaultResponse<UserModel>> changePassword(
    ChangePasswordRequest changePasswordRequest,
  );
  Future<DefaultResponse<List<NotificationResponse>>> getNotifications();
  Future<DefaultResponse<UserModel>> updateUserInfo(
    UserInfoRequest userInfoRequest,
  );
  Future<DefaultResponse<List<GiftResponse>>> getGiftList({
    bool isReceive = false,
  });
  Future<DefaultResponse> exchangeGift(int giftId);
  Future<DefaultResponse<List<UserModel>>> getStaffs({int isLike = 0});
  Future<DefaultResponse<List<UserModel>>> getListSupporters();
  Future<DefaultResponse> updateStaff(
    UpdateStaffRequestModel updateStaffRequestModel,
  );
  Future<DefaultResponse<List<UserModel>>> getListStaffByDistance(
    StaffByDistanceRequest staffByDistanceRequest,
  );
  Future<DefaultResponse> likeStaff(int id);
  Future<DefaultResponse> unlikeStaff(int id);
  Future<DefaultResponse<List<UserAddress>>> getListUserAddress();
  Future<DefaultResponse> createUserAddress(
    UserAddressRequest userAddressRequest,
  );
  Future<DefaultResponse> updateUserAddress(
    UserAddressRequest userAddressRequest,
  );
  Future<DefaultResponse> deleteUserAddress(String id);

  ///HOME
  Future<DefaultResponse<List<BlogModel>>> getBlogs({int page = 1});
  Future<DefaultResponse<List<BannerModel>>> getBanners();
  Future<DefaultResponse<List<ProductModel>>> getProducts({int isLike = 0});
  Future<DefaultResponse<List<HomeServiceModel>>> getServices();

  ///PRODUCT
  Future<DefaultResponse<List<ProductCategory>>> getProductCategory();
  Future<DefaultResponse<ProductCategory>> getProductCategoryDetail(int id);
  Future<DefaultResponse<ProductModel>> getProductDetail({
    required ProductModel product,
  });
  Future<DefaultResponse> likeProduct({
    required int productId,
    required bool isLike,
  });
  Future<DefaultResponse> getProductsInUse();

  ///MEDIA
  Future<DefaultResponse> uploadFile({required File file});

  ///SERVICE
  Future<DefaultResponse> createTask(CreateTaskRequest createTaskRequest);
  Future<DefaultResponse> updateTask(
    int id,
    UpdateTaskRequest updateTaskRequest,
  );
  Future<DefaultResponse> deleteTask(int id, String name, String des);
  Future<DefaultResponse<List<TaskModel>>> getListTask({int page = 1});
  Future<DefaultResponse<TaskModel>> getTask(int id);
  Future<DefaultResponse> storeAssignmentImage({
    required String id,
    required String note,
    required File image,
  });
  Future<DefaultResponse<UserProfile>> getKPIs(String userId);

  /// WALLET
  Future<DefaultResponse<WalletModel>> getWalletBalance();
  Future<DefaultResponse<List<WalletTransactionModel>>> getWalletTransactions({int? limit});
  Future<DefaultResponse> requestWalletAdvance({
    required double amount,
    int? orderId,
    String? note,
    List<File>? proofImages,
  });
  Future<DefaultResponse> requestWalletDeposit({
    required double amount,
    String? note,
    List<File>? proofImages,
  });
  Future<DefaultResponse> deleteTransaction(int transactionId);
}
