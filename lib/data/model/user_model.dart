import 'dart:convert';

import 'package:socbay/data/model/home_service_model.dart';
import 'package:socbay/data/model/task_model.dart';
import 'package:socbay/data/model/user_profile.dart';
import 'package:socbay/utils/parse_util.dart';

import 'order_model.dart';

class UserModel {
  final int? id;
  final String? username;
  final String? avatar;
  final String? companyAvatar;
  final String? email;
  final String? phone;
  final String? address;
  final String? password;
  final String? type;
  final String? typeStaff;
  final String? permition;
  final List<String> roles;
  final List<String> permissions;
  final int? otp;
  final String? birthday;
  final int? status;
  final int? isAgency;
  final int? isAdmin;
  final int? sex;
  final int? point;
  final double? lat;
  final double? lng;
  final double? distance;
  final String? createdAt;
  final String? certification;
  final List<HomeServiceModel>? services;
  final String? cmt;
  final String? idCardImageFront;
  final String? idCardImageBack;
  final TaskModel? taskmodel;
  final OrderModel? ordermodel;
  final UserProfile? userProfile;

  UserModel({
    this.username,
    this.avatar,
    this.companyAvatar,
    this.email,
    this.phone,
    this.address,
    this.password,
    this.type,
    this.typeStaff,
    this.permition,
    this.roles = const [],
    this.permissions = const [],
    this.otp,
    this.id,
    this.birthday,
    this.status,
    this.isAgency,
    this.isAdmin,
    this.sex,
    this.point,
    this.lat,
    this.lng,
    this.distance,
    this.createdAt,
    this.certification,
    this.services,
    this.taskmodel,
    this.ordermodel,
    this.cmt,
    this.idCardImageFront,
    this.idCardImageBack,
    this.userProfile,
  });

  static List<String> _parseStringList(dynamic raw) {
    if (raw == null) return const [];
    if (raw is List) {
      return raw
          .map((e) => e?.toString().trim() ?? '')
          .where((s) => s.isNotEmpty)
          .toList();
    }
    if (raw is String && raw.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          return decoded
              .map((e) => e?.toString().trim() ?? '')
              .where((s) => s.isNotEmpty)
              .toList();
        }
      } catch (_) {}
      return raw
          .split(',')
          .map((e) => e.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }
    return const [];
  }

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: Parse.toIntValue(json['id']),
    username: json['username'],
    avatar: json['avartar'] ?? json['avatar'],
    companyAvatar: json['company_avatar'],
    email: json['email'],
    phone: json['phone']?.toString(),
    address: json['address'],
    password: json['password'],
    type: json['type']?.toString(),
    typeStaff: json['type_staff']?.toString(),
    permition: json['permition']?.toString(),
    roles: _parseStringList(json['roles']),
    permissions: _parseStringList(json['permissions']),
    otp: Parse.toIntValue(json['otp']),
    birthday: json['birthday'],
    status: Parse.toIntValue(json['status']),
    isAgency: Parse.toIntValue(json['is_agency']),
    isAdmin: Parse.toIntValue(json['is_admin']),
    sex: Parse.toIntValue(json['sex']),
    point: Parse.toIntValue(json['tich_diem']),
    lat: Parse.toDoubleValue(json['lat']),
    lng: Parse.toDoubleValue(json['lng']),
    distance: Parse.toDoubleValue(json['distance']),
    createdAt: json['created_at'],
    certification: json['certification'],
    services: ((json['service'] as List<HomeServiceModel>?)?.map(
      (e) => e,
    ))?.toList(),
    taskmodel: json["customer"] != null
        ? TaskModel.fromJson(json["customer"])
        : null,
    ordermodel: json["listProducts"] != null
        ? OrderModel.fromJson(json["listProducts"])
        : null,
    cmt: json['cmt'],
    idCardImageFront: json['id_card_image_front'] ?? json['idCardImageFront'],
    idCardImageBack: json['id_card_image_back'] ?? json['idCardImageBack'],
    userProfile: json["user_profile"] != null
        ? UserProfile.fromJson(json["user_profile"])
        : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'avatar': avatar,
    'company_avatar': companyAvatar,
    'birthday': birthday,
    'phone': phone,
    'address': address,
    'status': status,
    'is_agency': isAgency,
    'type': type,
    'type_staff': typeStaff,
    'permition': permition,
    'roles': roles,
    'permissions': permissions,
    'is_admin': isAdmin,
    'sex': sex,
    'tich_diem': point,
    'lat': lat,
    'lng': lng,
    'distance': distance,
    'created_at': createdAt,
    'certification': certification,
    'services': services,
    'cmt': cmt,
    'idCardImageFront': idCardImageFront,
    'idCardImageBack': idCardImageBack,
    'user_profile': userProfile?.toJson(),
  };

  UserModel copyWith({
    int? id,
    String? username,
    String? avatar,
    String? companyAvatar,
    String? email,
    String? phone,
    String? address,
    String? password,
    String? type,
    String? typeStaff,
    String? permition,
    List<String>? roles,
    List<String>? permissions,
    int? otp,
    String? birthday,
    int? status,
    int? isAgency,
    int? isAdmin,
    int? sex,
    int? point,
    double? lat,
    double? lng,
    double? distance,
    String? createdAt,
    String? certification,
    List<HomeServiceModel>? services,
    String? cmt,
    String? idCardImageFront,
    String? idCardImageBack,
    TaskModel? taskmodel,
    OrderModel? ordermodel,
    UserProfile? userProfile,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      avatar: avatar ?? this.avatar,
      companyAvatar: companyAvatar ?? this.companyAvatar,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      password: password ?? this.password,
      type: type ?? this.type,
      typeStaff: typeStaff ?? this.typeStaff,
      permition: permition ?? this.permition,
      roles: roles ?? this.roles,
      permissions: permissions ?? this.permissions,
      otp: otp ?? this.otp,
      birthday: birthday ?? this.birthday,
      status: status ?? this.status,
      isAgency: isAgency ?? this.isAgency,
      isAdmin: isAdmin ?? this.isAdmin,
      sex: sex ?? this.sex,
      point: point ?? this.point,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      distance: distance ?? this.distance,
      createdAt: createdAt ?? this.createdAt,
      certification: certification ?? this.certification,
      services: services ?? this.services,
      cmt: cmt ?? this.cmt,
      idCardImageFront: idCardImageFront ?? this.idCardImageFront,
      idCardImageBack: idCardImageBack ?? this.idCardImageBack,
      taskmodel: taskmodel ?? this.taskmodel,
      ordermodel: ordermodel ?? this.ordermodel,
      userProfile: userProfile ?? this.userProfile,
    );
  }

  // ==================== RBAC HELPERS ====================
  bool get isSuperAdmin =>
      roles.contains('super-admin') || roles.contains('admin') || isAdmin == 1;

  bool hasRole(String role) => isSuperAdmin || roles.contains(role);

  bool hasAnyRole(List<String> targetRoles) =>
      isSuperAdmin || targetRoles.any((r) => roles.contains(r));

  bool hasPermission(String perm) => isSuperAdmin || permissions.contains(perm);

  bool hasAnyPermission(List<String> perms) =>
      isSuperAdmin || perms.any((p) => permissions.contains(p));

  bool get isCoordinatorOrAdmin =>
      hasAnyRole(['super-admin', 'admin', 'socbay', 'sales-manager']) ||
      hasAnyPermission(['tasks.view-all', 'rent-tasks.view-all']) ||
      [163, 12985, 2438, 9309].contains(id);

  bool get isKtvRole =>
      hasRole('ktv') || (type == "2" && ["1", "3", "5"].contains(typeStaff));

  bool get isSaleRole =>
      hasAnyRole(['sales', 'sales-manager']) ||
      (type == "2" && typeStaff == "2");

  // ==================== APP ROLE CHECKS ====================
  /// Quy tắc 1: Khách hàng (`type == 0` / `type == "1"` và `type_staff == 0`) GIỮ NGUYÊN logic cũ
  bool isUserCustomer() =>
      (type == "1" || type == "0") && (typeStaff == "0" || typeStaff == null);

  /// Quy tắc 2: KTV (kèm fallback tương thích ngược)
  bool isUserRole() =>
      !isUserCustomer() &&
      (isKtvRole ||
          (!isSaleRole &&
              !isCoordinatorOrAdmin &&
              type != "1" &&
              ["0", "1", "3", "5"].contains(typeStaff)));

  /// Quy tắc 2: Sale / Điều phối / Quản lý / Kế toán (kèm fallback tương thích ngược)
  bool isUserSale() =>
      !isUserCustomer() &&
      (isSaleRole ||
          isCoordinatorOrAdmin ||
          hasAnyRole([
            'socbay',
            'warehouse',
            'nhansu',
            'ke-toan-online',
            'shopee-manager',
          ]) ||
          (!isKtvRole &&
              type != "1" &&
              ["2", "4", "6", "7", "8"].contains(typeStaff)));

  // ==================== MODULE PERMISSION GETTERS ====================
  // 1. Module Công việc sửa chữa / lắp đặt (tasks)
  bool get canViewAllTasks =>
      hasAnyRole(['super-admin', 'admin', 'socbay', 'sales-manager']) ||
      hasPermission('tasks.view-all') ||
      [163, 12985, 2438].contains(id);

  bool get canAddTask =>
      hasPermission('tasks.add') || isUserSale() || isUserCustomer();

  bool get canEditTask => hasPermission('tasks.edit') || isUserSale();

  bool get canAssignTask => hasPermission('tasks.change-task') || isUserSale();

  bool get canDeleteTask => hasPermission('tasks.del') || isUserSale();

  bool get canAcceptTask => hasPermission('tasks.accept') || isUserRole();

  bool get canCompleteTask =>
      hasPermission('tasks.complete') || isUserRole() || isUserSale();

  bool get canUpdateTaskAddress =>
      hasPermission('tasks.update-address') || isUserCustomer() || isUserRole();

  bool get canViewTaskTimeline =>
      hasPermission('tasks.timeline') || isUserRole() || isUserSale();

  // 2. Module Công việc thuê máy (rent-tasks)
  bool get canViewAllRentTasks =>
      hasAnyRole(['super-admin', 'admin', 'socbay', 'sales-manager']) ||
      hasPermission('rent-tasks.view-all') ||
      [163, 12985, 2438].contains(id);

  bool get canAddRentTask =>
      hasPermission('rent-tasks.add') || isUserSale() || isUserCustomer();

  bool get canEditRentTask => hasPermission('rent-tasks.edit') || isUserSale();

  bool get canAssignRentTask =>
      hasPermission('rent-tasks.change-task') || isUserSale();

  bool get canDeleteRentTask => hasPermission('rent-tasks.del') || isUserSale();

  bool get canAcceptRentTask =>
      hasPermission('rent-tasks.accept') || isUserRole();

  bool get canCompleteRentTask =>
      hasPermission('rent-tasks.complete') || isUserRole() || isUserSale();

  bool get canUpdateRentTaskAddress =>
      hasPermission('rent-tasks.update-address') ||
      isUserCustomer() ||
      isUserRole();

  // 3. Module Ví KTV (ktv-wallets)
  bool get canUseKtvWallet =>
      hasAnyPermission(['ktv-wallets.show', 'ktv-wallets.transactions']) ||
      isUserRole() ||
      isUserSale();

  bool get canRequestWalletAdvance =>
      hasPermission('ktv-wallets.request-advance') ||
      isUserRole() ||
      isUserSale();

  bool get canRequestWalletDeposit =>
      hasPermission('ktv-wallets.request-deposit') ||
      isUserRole() ||
      isUserSale();

  bool get canDeleteWalletTransaction =>
      hasPermission('ktv-wallets.delete-transaction') ||
      isUserRole() ||
      isUserSale();

  bool get canManageKtvWallet =>
      hasAnyPermission([
        'ktv-wallets.index',
        'ktv-wallets.verify',
        'ktv-wallets.adjust',
      ]) ||
      isCoordinatorOrAdmin;

  // 4. Module Đơn dịch vụ, Doanh thu & Thanh toán (service-orders, order-payments)
  bool get canCreateServiceOrder =>
      hasAnyPermission([
        'service-orders.add-order',
        'service-orders.store',
        'service-orders.save-repair',
      ]) ||
      isUserRole() ||
      isUserSale();

  bool get canViewSalesIncomeBySale =>
      hasPermission('service-orders.sales-income') ||
      (!isUserRole() && isUserSale());

  bool get canViewOrdersBySale =>
      hasPermission('service-orders.list-by-sale') || isUserSale();

  bool get canViewOrdersByStaff =>
      hasPermission('service-orders.list-by-staff') || isUserRole();

  bool get canUploadPaymentProof =>
      hasPermission('order-payments.upload-proof') ||
      isUserRole() ||
      isUserSale();

  // 5. Module Định vị & Hành trình KTV (technician-locations)
  bool get canTrackTechnicianLocation =>
      hasAnyPermission([
        'technician-locations.update',
        'technician-locations.start-trip',
        'technician-locations.stop-trip',
      ]) ||
      isUserRole();

  bool get canViewTechnicianLocations =>
      hasAnyPermission([
        'technician-locations.realtime',
        'technician-locations.history',
      ]) ||
      isCoordinatorOrAdmin;

  // 6. Module Báo giá (services-quotation) & Phản hồi (feedbacks)
  bool get canViewFeedbacks =>
      hasAnyPermission(['feedbacks.index', 'feedbacks.show']) ||
      isUserRole() ||
      isUserSale();

  bool get canUpdateFeedback =>
      hasPermission('feedbacks.update') || isUserRole() || isUserSale();

  String get roleDisplayName {
    if (roles.contains('super-admin') || roles.contains('admin')) {
      return 'Quản trị viên';
    }
    if (roles.contains('sales-manager')) return 'Quản lý kinh doanh';
    if (roles.contains('socbay')) return 'Điều phối viên Sóc Bay';
    if (roles.contains('sales')) return 'Kinh doanh';
    if (roles.contains('ktv')) return 'Kỹ thuật viên';
    if (roles.contains('ke-toan-online')) return 'Kế toán';
    if (roles.contains('warehouse')) return 'Thủ kho';
    if (roles.contains('nhansu')) return 'Nhân sự';
    if (roles.contains('shopee-manager')) return 'Quản lý Shopee';

    switch (typeStaff) {
      case '1':
        return 'Nhân viên giao hàng';
      case '2':
        return 'Kinh doanh';
      case '3':
        return 'Kỹ thuật viên';
      case '4':
        return 'Chăm sóc khách hàng';
      case '5':
        return 'Cộng tác viên lắp đặt';
      case '6':
        return 'Điều phối viên Sóc Bay';
      case '7':
        return 'Kế toán';
      case '8':
        return 'Thủ kho';
      default:
        return 'Nhân viên';
    }
  }
}
