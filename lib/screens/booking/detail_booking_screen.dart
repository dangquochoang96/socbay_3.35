import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:full_screen_image_null_safe/full_screen_image_null_safe.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:socbay/utils/auth_http.dart' as http;
import 'package:intl/intl.dart';
import 'package:socbay/application.dart';
import 'package:socbay/blocs/booking/detail_booking/detail_booking_bloc.dart';
import 'package:socbay/blocs/booking/detail_booking/detail_booking_event.dart';
import 'package:socbay/blocs/booking/detail_booking/detail_booking_state.dart';
import 'package:socbay/blocs/booking/detail_booking/detail_rent_booking_bloc.dart';
import 'package:socbay/blocs/task/task_screen_event.dart';
import 'package:socbay/blocs/task/task_screen_sale_bloc.dart';
import 'package:socbay/blocs/rent-task/rent_task_screen_event.dart'
    as rent_event;
import 'package:socbay/blocs/rent-task/rent_task_screen_bloc.dart';
import 'package:socbay/config/app_config.dart';
import 'package:socbay/constants/maps.dart';
import 'package:socbay/data/data_provider/api_endpoints.dart';
import 'package:socbay/data/model/home_service_model.dart';
import 'package:socbay/data/model/order_detail_model.dart';
import 'package:socbay/data/model/task_model.dart';
import 'package:socbay/routes.dart';
import 'package:socbay/utils/color_util.dart';
import 'package:socbay/utils/image_util.dart';
import 'package:socbay/utils/logger_util.dart';
import 'package:socbay/widgets/button_widget.dart';
import 'package:socbay/widgets/loading_indicator.dart';
import 'package:socbay/widgets/my_app_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:android_intent_plus/android_intent.dart';

class DetailBookingScreen extends StatefulWidget {
  final bool isRent;
  const DetailBookingScreen({super.key, this.isRent = false});

  @override
  State<DetailBookingScreen> createState() => _DetailBookingScreenState();
}

class _DetailBookingScreenState extends State<DetailBookingScreen> {
  late dynamic _bloc;
  late dynamic _taskScreenSaleBloc;
  String? _selectedTaskType;
  bool _isUpdatingAddress = false;

  Future<void> _updateAddressLocation() async {
    if (_bloc.taskModel?.id == null) return;

    setState(() {
      _isUpdatingAddress = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Vui lòng bật dịch vụ định vị (GPS) để cập nhật địa chỉ.',
              ),
            ),
          );
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Quyền truy cập vị trí bị từ chối.'),
              ),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Quyền vị trí bị từ chối vĩnh viễn. Vui lòng mở Cài đặt ứng dụng để cấp quyền.',
              ),
            ),
          );
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      String addressString = '${position.latitude}, ${position.longitude}';
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          List<String> parts = [];
          if (p.street != null && p.street!.trim().isNotEmpty) {
            parts.add(p.street!.trim());
          }
          if (p.subAdministrativeArea != null &&
              p.subAdministrativeArea!.trim().isNotEmpty) {
            parts.add(p.subAdministrativeArea!.trim());
          }
          if (p.administrativeArea != null &&
              p.administrativeArea!.trim().isNotEmpty) {
            parts.add(p.administrativeArea!.trim());
          }
          if (p.country != null && p.country!.trim().isNotEmpty) {
            parts.add(p.country!.trim());
          }
          if (parts.isNotEmpty) {
            addressString = parts.join(', ');
          }
        }
      } catch (e) {
        LoggerUtil.error("Error reverse geocoding: $e");
      }

      final String endpoint = widget.isRent
          ? ApiEndpoints.rentTaskUpdateAddress(_bloc.taskModel!.id)
          : ApiEndpoints.taskUpdateAddress(_bloc.taskModel!.id);
      final url = AppConfig.instance.apiUri(endpoint);

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: {'current_address': addressString},
      );

      if (response.statusCode == HttpStatus.ok) {
        final data = Map<String, dynamic>.from(json.decode(response.body));
        if (data['code'] == 1) {
          if (data['data'] != null) {
            try {
              _bloc.taskModel = TaskModel.fromJson(data['data']);
            } catch (e) {
              LoggerUtil.error("Error parsing updated taskModel: $e");
            }
          }
          if (mounted) {
            setState(() {});
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Cập nhật địa chỉ thành công!')),
            );
          }
          _bloc.add(DetailBookingStartedEvent());
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(data['message'] ?? 'Cập nhật địa chỉ thất bại'),
              ),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Lỗi phản hồi từ máy chủ (Mã: ${response.statusCode})',
              ),
            ),
          );
        }
      }
    } catch (e) {
      LoggerUtil.error("Error updating address: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Có lỗi xảy ra: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingAddress = false;
        });
      }
    }
  }

  @override
  void initState() {
    if (widget.isRent) {
      _bloc = BlocProvider.of<DetailRentBookingBloc>(context);
      _taskScreenSaleBloc = BlocProvider.of<RentTaskScreenSaleBloc>(context);
    } else {
      _bloc = BlocProvider.of<DetailBookingBloc>(context);
      _taskScreenSaleBloc = BlocProvider.of<TaskScreenSaleBloc>(context);
    }
    _bloc.add(DetailBookingStartedEvent());
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isRent) {
      return BlocConsumer<DetailRentBookingBloc, DetailBookingState>(
        builder: _builder,
        listener: _listener,
      );
    } else {
      return BlocConsumer<DetailBookingBloc, DetailBookingState>(
        builder: _builder,
        listener: _listener,
      );
    }
  }

  void _listener(BuildContext context, DetailBookingState state) {}

  Widget _builder(BuildContext context, DetailBookingState state) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: MyAppBar(
        titleWidget: GestureDetector(
          //onTap: onTapTitleWidget,
          child: RichText(
            text: TextSpan(
              children: <TextSpan>[
                //  khách hàng
                if (App.instance.userApp?.isUserCustomer() == true)
                  const TextSpan(
                    text: 'Chi tiết đặt lịch ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                      fontSize: 18,
                      color: ColorUtil.white,
                    ),
                  ),
                //  kỹ thuật
                if (App.instance.userApp?.isUserRole() == true)
                  const TextSpan(
                    text: 'Chi tiết công việc KT ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                      fontSize: 18,
                      color: ColorUtil.white,
                    ),
                  ),
                if (App.instance.userApp?.isUserSale() == true)
                  const TextSpan(
                    text: 'Chi tiết công việc ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                      fontSize: 18,
                      color: ColorUtil.white,
                    ),
                  ),
                TextSpan(
                  text: '${_bloc.taskModel?.id}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                    fontSize: 18,
                    color: ColorUtil.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        isBackNavigation: true,
        title: 'Chi tiết đơn hàng ${_bloc.taskModel?.id}',
        centerTitle: true,
        actionWidgets: [
          if (App.instance.userApp?.isUserCustomer() == true)
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  Routes.feedbackScreen,
                  arguments: {
                    'history_id': _bloc.taskModel?.id?.toString(),
                    'taskId': _bloc.taskModel?.id?.toString(),
                    'staffName': _bloc.taskModel?.staff?.username,
                    'staffPhone': _bloc.taskModel?.staff?.phone,
                  },
                );
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Center(
                  child: Text(
                    'Góp ý',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: ColorUtil.white,
                    ),
                  ),
                ),
              ),
            ),
          if ((_bloc.taskModel?.status == '1' ||
                  _bloc.taskModel?.status == '2' ||
                  _bloc.taskModel?.status == '5') &&
              _bloc.taskModel?.userCreate ==
                  App.instance.userApp?.id.toString()) ...[
            GestureDetector(
              onTap: () {
                _editBooking(_bloc.taskModel?.id ?? 0);
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Center(
                  child: Text(
                    'Sửa',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
      body: LoadingIndicator(
        isLoading: _bloc.isLoading,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildGeneralInfoCard(_bloc.taskModel),
            _buildProductInfoCard(_bloc.taskModel),
            if (App.instance.userApp?.isUserCustomer() == false)
              _buildCustomerInfoCard(_bloc.taskModel),
            _buildMediaCard(),
            const SizedBox(height: 16),
            if (App.instance.userApp?.isUserCustomer() == true)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    _buildButton(
                      text: 'GÓP Ý',
                      isPositive: true,
                      action: () {
                        Navigator.pushNamed(
                          context,
                          Routes.feedbackScreen,
                          arguments: {
                            'history_id': _bloc.taskModel?.id?.toString(),
                            'taskId': _bloc.taskModel?.id?.toString(),
                            'staffName': _bloc.taskModel?.staff?.username,
                            'staffPhone': _bloc.taskModel?.staff?.phone,
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            if (App.instance.userApp?.isUserRole() == true) ...[
              if (_bloc.taskModel?.status == "3") _detailTask(),
              if (_bloc.taskModel?.status != "3" &&
                  _bloc.taskModel?.status != "4" &&
                  !(App.instance.userApp?.isUserCustomer() == true))
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      _buildButton(
                        text: 'TẠO HÓA ĐƠN',
                        isPositive: true,
                        action: () {
                          _createOrder(_bloc.taskModel?.id ?? 0);
                        },
                      ),
                    ],
                  ),
                ),
            ],
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralInfoCard(TaskModel? taskModel) {
    final String? effectiveType = _selectedTaskType ?? taskModel?.type;
    final bool typeExists = HomeServiceModel.taskServiceList.any(
      (element) => element.id.toString() == effectiveType,
    );
    final String? dropdownValue = typeExists ? effectiveType : null;

    return _buildCard(
      title: "Thông tin chung",
      icon: Icons.info_outline,
      child: Column(
        children: [
          _buildInfoRow(
            "Thời gian:",
            _formatDatetime(taskModel?.timeStart),
            valueColor: ColorUtil.red,
            isBold: true,
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    "Công việc:",
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: ColorUtil.bangladeshGreen,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: dropdownValue,
                        isExpanded: true,
                        hint: const Text(
                          "Chọn loại CV",
                          style: TextStyle(fontSize: 13),
                        ),
                        style: const TextStyle(
                          fontSize: 14,
                          color: ColorUtil.raisinBlack,
                          fontWeight: FontWeight.w500,
                        ),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedTaskType = newValue;
                          });
                        },
                        items: HomeServiceModel.taskServiceList.map((
                          HomeServiceModel sv,
                        ) {
                          return DropdownMenuItem<String>(
                            value: sv.id.toString(),
                            child: Text(
                              sv.name ?? "",
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildInfoRow(
            "Trạng thái:",
            taskModel?.getStatus() ?? "",
            valueColor: ColorUtil.red,
            isBold: true,
          ),
          if (taskModel?.staff?.username != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      "Kỹ thuật viên:",
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          Routes.staffCommentTechniqueList,
                          arguments: {
                            "id": taskModel?.staff?.id,
                            "name": taskModel?.staff?.username,
                            "staffInfo": taskModel?.staff,
                          },
                        );
                      },
                      child: Text(
                        taskModel?.staff?.username ?? "",
                        style: const TextStyle(
                          fontSize: 14,
                          color: ColorUtil.bangladeshGreen,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (taskModel?.staff?.phone != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      "SĐT KTV:",
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: GestureDetector(
                      onTap: () {
                        var url = "tel:${taskModel!.staff!.phone!}";
                        launchUrl(Uri.parse(url));
                      },
                      child: Text(
                        taskModel?.staff?.phone ?? "",
                        style: const TextStyle(
                          fontSize: 14,
                          color: ColorUtil.bangladeshGreen,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (taskModel?.noti != null && taskModel!.noti!.isNotEmpty)
            _buildInfoRow(
              "Thông báo:",
              taskModel.noti!,
              valueColor: ColorUtil.red,
            ),
        ],
      ),
    );
  }

  Widget _buildCurrentAddressRow(TaskModel? taskModel) {
    if (taskModel?.currentAddress == null ||
        taskModel!.currentAddress!.trim().isEmpty) {
      return const SizedBox();
    }
    final addressText = taskModel.currentAddress!.trim();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              "Vị trí hiện tại (Google Maps):",
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ),
          Expanded(
            flex: 3,
            child: GestureDetector(
              onTap: () async {
                if (isAndroid) {
                  final AndroidIntent intent = AndroidIntent(
                    action: 'action_view',
                    data:
                        'google.navigation:q=${Uri.encodeComponent(addressText)}',
                    package: 'package:com.google.android.apps.maps',
                  );
                  await intent.launch();
                } else {
                  commonLaunchUrl(
                    '$GOOGLE_MAP_PREFIX${Uri.encodeFull(addressText)}',
                    launchMode: LaunchMode.externalApplication,
                  );
                }
              },
              child: Text(
                addressText,
                style: const TextStyle(
                  fontSize: 14,
                  color: ColorUtil.bangladeshGreen,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationUpdateButton() {
    return InkWell(
      onTap: _isUpdatingAddress ? null : _updateAddressLocation,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: ColorUtil.bangladeshGreen.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: ColorUtil.bangladeshGreen, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isUpdatingAddress)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: ColorUtil.bangladeshGreen,
                ),
              )
            else
              const Icon(
                Icons.my_location,
                color: ColorUtil.bangladeshGreen,
                size: 18,
              ),
            const SizedBox(width: 8),
            Text(
              _isUpdatingAddress
                  ? "Đang lấy vị trí..."
                  : "Cập nhật địa chỉ hiện tại",
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: ColorUtil.bangladeshGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductInfoCard(TaskModel? taskModel) {
    return _buildCard(
      title: "Thông tin thiết bị & Yêu cầu",
      icon: Icons.kitchen_outlined,
      child: Column(
        children: [
          _buildInfoRow(
            "Tên sản phẩm:",
            taskModel?.productInfo?.machineModel?.name ?? "",
          ),
          _buildInfoRow("Nội dung:", taskModel?.des ?? ""),
          if (App.instance.userApp?.isUserCustomer() == true)
            _buildInfoRow(
              "Vị trí lắp đặt:",
              taskModel?.productInfo?.address ?? "",
            ),
          if (App.instance.userApp?.isUserCustomer() == true) ...[
            _buildCurrentAddressRow(taskModel),
            const SizedBox(height: 8),
            _buildLocationUpdateButton(),
          ],
        ],
      ),
    );
  }

  Widget _buildCustomerInfoCard(TaskModel? taskModel) {
    return _buildCard(
      title: "Thông tin khách hàng",
      icon: Icons.person_outline,
      child: Column(
        children: [
          if (taskModel?.customer?.phone != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      "Số điện thoại:",
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: GestureDetector(
                      onTap: () {
                        var url = "tel:${taskModel!.customer!.phone!}";
                        launchUrl(Uri.parse(url));
                      },
                      child: Text(
                        taskModel?.customer?.phone ?? "",
                        style: const TextStyle(
                          fontSize: 14,
                          color: ColorUtil.bangladeshGreen,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (taskModel?.customer?.address != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      "Địa chỉ:",
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: GestureDetector(
                      onTap: () async {
                        if (isAndroid) {
                          final AndroidIntent intent = AndroidIntent(
                            action: 'action_view',
                            data:
                                'google.navigation:q=${taskModel?.customer?.address ?? ""}',
                            package: 'package:com.google.android.apps.maps',
                          );
                          await intent.launch();
                        } else {
                          commonLaunchUrl(
                            '$GOOGLE_MAP_PREFIX${Uri.encodeFull(taskModel?.customer?.address ?? "")}',
                            launchMode: LaunchMode.externalApplication,
                          );
                        }
                      },
                      child: Text(
                        taskModel?.customer?.address ?? "",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (taskModel?.productInfo?.address != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      "Vị trí lắp đặt:",
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: GestureDetector(
                      onTap: () async {
                        if (isAndroid) {
                          final AndroidIntent intent = AndroidIntent(
                            action: 'action_view',
                            data:
                                'google.navigation:q=${taskModel?.productInfo?.address ?? ""}',
                            package: 'package:com.google.android.apps.maps',
                          );
                          await intent.launch();
                        } else {
                          commonLaunchUrl(
                            '$GOOGLE_MAP_PREFIX${Uri.encodeFull(taskModel?.productInfo?.address ?? "")}',
                            launchMode: LaunchMode.externalApplication,
                          );
                        }
                      },
                      child: Text(
                        taskModel?.productInfo?.address ?? "",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF1976D2),
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          _buildCurrentAddressRow(taskModel),
        ],
      ),
    );
  }

  Widget _buildMediaCard() {
    if (_bloc.taskModel == null ||
        _bloc.taskModel!.images == null ||
        _bloc.taskModel!.images!.isEmpty) {
      return const SizedBox();
    }
    return _buildCard(
      title: "Hình ảnh / Video đính kèm",
      icon: Icons.attach_file_outlined,
      child: SizedBox(
        height: 100,
        width: double.infinity,
        child: ListView.builder(
          itemCount: _bloc.taskModel!.images?.length,
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemBuilder: (BuildContext context, int index) {
            String url = _bloc.taskModel!.images![index].isEmpty
                ? ""
                : "$protocol${AppConfig.instance.values.apiUrl}${_bloc.taskModel!.images![index]}";

            bool isVideo =
                url.toLowerCase().endsWith('.mp4') ||
                url.toLowerCase().endsWith('.mov') ||
                url.toLowerCase().endsWith('.avi');

            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: isVideo ? _videoWidget(url) : _fullScreenHeroWidget(url),
            );
          },
        ),
      ),
    );
  }

  Widget _videoWidget(String url) {
    return GestureDetector(
      onTap: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Icon(Icons.play_circle_fill, size: 40, color: Colors.black54),
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required Widget child,
    IconData? icon,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: ColorUtil.bangladeshGreen.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, color: ColorUtil.bangladeshGreen, size: 20),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: ColorUtil.bangladeshGreen,
                    ),
                  ),
                ),
                if (trailing != null) trailing,
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    Color? valueColor,
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                color: valueColor ?? ColorUtil.raisinBlack,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailTask() {
    if (_bloc.taskModel?.status == '3') {
      return Container(
        alignment: Alignment.center,
        child: _builderTaskProcessedDetail(_bloc.taskModel),
      );
    } else {
      return const SizedBox();
    }
  }

  void _editBooking(int id) {
    Navigator.pushNamed(
      context,
      widget.isRent ? Routes.editRentServiceScreen : Routes.editServiceScreen,
      arguments: {'id': id},
    ).then((value) async {
      if (value == null) {
        return;
      } else {
        Map<String, dynamic>? result = value as Map<String, dynamic>?;
        if (result != null) {
          setState(() {
            _selectedTaskType = null;
            _bloc.add(DetailBookingStartedEvent());
            if (widget.isRent) {
              _taskScreenSaleBloc.add(
                const rent_event.StaffTaskScreenGetTaskAssigedEvent(
                  isRefresh: true,
                ),
              );
              _taskScreenSaleBloc.add(
                const rent_event.StaffTaskScreenGetTaskByDayEvent(
                  isRefresh: true,
                ),
              );
            } else {
              _taskScreenSaleBloc.add(
                const StaffTaskScreenGetTaskAssigedEvent(isRefresh: true),
              );
              _taskScreenSaleBloc.add(
                const StaffTaskScreenGetTaskByDayEvent(isRefresh: true),
              );
            }
          });
        }
      }
    });
  }

  Widget _fullScreenHeroWidget(String img) {
    return SizedBox(
      width: 100,
      height: 100,
      child: FullScreenWidget(
        child: Hero(
          tag: img,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: ImageUtil.loadNetWorkImage(
              url: img,
              height: 100,
              fit: BoxFit.contain,
            ),
            //fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _builderTaskProcessedDetail(TaskModel? taskModel) {
    return taskModel?.id != null
        ? ButtonWidget(
            color: ColorUtil.bangladeshGreen,
            borderRadius: BorderRadius.circular(30),
            padding: const EdgeInsets.all(10),
            onTap: () => {
              // Navigator.pushNamed(context, Routes.detailTaskProcessedScreen,
              //     arguments: {"id": taskModel?.id})
              Navigator.pushNamed(
                context,
                Routes.coreReplacementServiceScreen,
                arguments: {
                  "orderDetail": OrderDetailModel(
                    id: int.tryParse(_bloc.taskModel?.orderId ?? "") ?? 0,
                  ),
                },
              ),
            },
            child: const Text(
              "Xem chi tiết Xử lý",
              style: TextStyle(color: ColorUtil.white),
            ),
          )
        : const SizedBox();
  }

  String _formatDatetime(String? dateTimeString) {
    try {
      var dateTime = dateTimeString ?? DateTime.now().toString();
      DateTime getDateTime = DateTime.parse(dateTime);
      var output = DateFormat('dd/MM/yyyy HH:mm:ss').format(getDateTime);
      return output.toString();
    } on Exception catch (ex) {
      LoggerUtil.error("format datetime error: $ex");
      rethrow;
    }
  }

  Widget _buildButton({text, isPositive, action}) {
    return Expanded(
      child: isPositive
          ? _button(isPositive, action, text)
          : ElevatedButton(
              style: ButtonStyle(
                padding: WidgetStateProperty.all<EdgeInsets>(
                  const EdgeInsets.symmetric(vertical: 10),
                ),
                backgroundColor: WidgetStateProperty.all<Color>(
                  ColorUtil.white,
                ),
                shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: const BorderSide(
                      color: ColorUtil.bangladeshGreen,
                      width: 2,
                    ),
                  ),
                ),
              ),
              child: Text(
                text,
                style: const TextStyle(color: ColorUtil.bangladeshGreen),
              ),
              onPressed: () {
                if (action == null) {
                  Navigator.pop(context);
                } else {
                  action();
                }
              },
            ),
    );
  }

  StatelessWidget _button(isPositive, action, text) {
    return ButtonWidget(
      color: isPositive ? ColorUtil.bangladeshGreen : Colors.grey,
      borderRadius: BorderRadius.circular(30),
      padding: const EdgeInsets.symmetric(vertical: 10),
      margin: const EdgeInsets.only(left: 60.0, right: 60, bottom: 30, top: 10),
      onTap: () {
        if (action == null) {
          Navigator.pop(context);
        } else {
          action();
        }
      },
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 20, color: Colors.white),
      ),
    );
  }

  void _createOrder(int id) {
    final String? effectiveType = _selectedTaskType ?? _bloc.taskModel?.type;
    Navigator.pushNamed(
      context,
      widget.isRent ? Routes.createRentOrderScreen : Routes.createOrderScreen,
      arguments: {'id': id, 'taskType': effectiveType},
    );
  }
}
