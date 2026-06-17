import '../../paths/images.dart';

class HomeServiceModel {
  int? id;
  //String? app;
  String? name;
  String? image;
  String? type;
  String? status;
  String? order;
  String? des;
  String? createdAt;
  String? updatedAt;

  HomeServiceModel({
    this.id,
    this.name,
    this.image,
    this.type,
    this.status,
    this.order,
    this.des,
    this.createdAt,
    this.updatedAt,
  });

  factory HomeServiceModel.fromJson(Map<String, dynamic> json) =>
      HomeServiceModel(
        id: json['id'] as int?,
        name: json['name'] as String?,
        image: json['image'] as String?,
        type: json['type'] as String?,
        status: json['status'] as String?,
        order: json['order'] as String?,
        des: json['des'] as String?,
        createdAt: json['createdAt'] as String?,
        updatedAt: json['updatedAt'] as String?,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'name': name,
    'image': image,
    'type': type,
    'status': status,
    'order': order,
    'des': des,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };

  static List<HomeServiceModel> serviceList = [
    HomeServiceModel(
      image: Images.iconMaintenance,
      des: 'Dịch vụ khách hàng',
      name: 'ĐẶT LỊCH DỊCH VỤ',
    ),
    HomeServiceModel(
      image: Images.iconAdvise,
      des: 'Hỗ trợ & tư vấn dịch vụ',
      name: 'TƯ VẤN',
    ),
    HomeServiceModel(
      // image: Images.iconFeedback,
      image: Images.iconRemovComen,
      des: 'Góp ý & khiếu nại',
      name: 'GÓP Ý & KHIẾU NẠI',
    ),
    HomeServiceModel(
      image: Images.iconHotline,
      des: 'Liên hệ Hotline',
      name: 'HOTLINE',
    ),
    HomeServiceModel(
      image: Images.iconReplace,
      des: 'Ngày thay tiếp theo',
      name: 'NGÀY THAY TIẾP THEO',
    ),
  ];
  static List<HomeServiceModel> staffServiceList = [
    HomeServiceModel(
      image: Images.iconAdvise,
      des: 'Đánh giá & nhận xét',
      name: 'Đánh giá & nhận xét',
    ),
    HomeServiceModel(
      image: Images.iconFeedback,
      des: 'Đơn hàng',
      name: 'Quản lý đơn hàng',
    ),
    HomeServiceModel(
      image: Images.iconinventory,
      des: 'Góp ý & khiếu nại',
      name: 'GÓP Ý & KHIẾU NẠI',
    ),
    HomeServiceModel(
      image: Images.iconNews,
      des: 'Quản lý đơn nhập vật liệu',
      name: 'Nhập Vật Liệu',
    ),
    HomeServiceModel(
      image: Images.iconinventory,
      des: 'Kho Cá Nhân của KTV',
      name: 'KHO CÁ NHÂN',
    ),
  ];
  static List<HomeServiceModel> staffServiceListSale = [
    HomeServiceModel(
      image: Images.iconRemovComen,
      des: 'Đánh giá & nhận xét kỹ thuật',
      name: 'Đánh giá & nhận xét',
    ),
    HomeServiceModel(
      image: Images.iconinventory,
      des: 'Quản lý đơn hàng',
      name: 'Đơn hàng',
    ),
    HomeServiceModel(
      image: Images.iconFeedback,
      des: 'Góp ý & khiếu nại kỹ thuật',
      name: 'GÓP Ý & KHIẾU NẠI',
    ),
    HomeServiceModel(
      image: Images.iconCrowd,
      des: 'Thông tin khách hàng',
      name: 'Thông tin khách hàng',
    ),
  ];
  static List<HomeServiceModel> taskServiceList = [
    HomeServiceModel(
      id: 1,
      image: Images.iconAdvise,
      des: 'VS Bảo dưỡng',
      name: 'VS Bảo dưỡng',
    ),
    HomeServiceModel(
      id: 2,
      image: Images.iconAdvise,
      des: 'Thay lõi + VS',
      name: 'Thay lõi + VS',
    ),
    HomeServiceModel(
      id: 3,
      image: Images.iconAdvise,
      des: 'Sửa máy + VS',
      name: 'Sửa máy + VS',
    ),
    HomeServiceModel(
      id: 4,
      image: Images.iconAdvise,
      des: 'Lắp máy',
      name: 'Lắp máy',
    ),
    HomeServiceModel(
      id: 5,
      image: Images.iconAdvise,
      des: 'Chuyển máy',
      name: 'Chuyển máy',
    ),
    HomeServiceModel(
      id: 6,
      image: Images.iconAdvise,
      des: 'Khác',
      name: 'Khác',
    ),
  ];
  static List<HomeServiceModel> getServiceList() {
    return [
      HomeServiceModel(
        id: 1,
        image: Images.iconAdvise,
        des: 'VS Bảo dưỡng',
        name: 'VS Bảo dưỡng',
      ),
      HomeServiceModel(
        id: 2,
        image: Images.iconAdvise,
        des: 'Thay lõi + VS',
        name: 'Thay lõi + VS',
      ),
      HomeServiceModel(
        id: 3,
        image: Images.iconAdvise,
        des: 'Sửa máy + VS',
        name: 'Sửa máy + VS',
      ),
      HomeServiceModel(
        id: 4,
        image: Images.iconAdvise,
        des: 'Lắp máy',
        name: 'Lắp máy',
      ),
      HomeServiceModel(
        id: 5,
        image: Images.iconAdvise,
        des: 'Chuyển máy',
        name: 'Chuyển máy',
      ),
      HomeServiceModel(
        id: 6,
        image: Images.iconAdvise,
        des: 'Khác',
        name: 'Khác',
      ),
    ];
  }
}
