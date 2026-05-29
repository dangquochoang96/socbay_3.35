// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:socbay/blocs/staff/new_task_sale/staff_service_screen_sale_bloc.dart';
import 'package:location/location.dart' as location_dart;
import 'package:socbay/blocs/staff/new_task_sale/staff_service_screen_sale_event.dart';
import 'package:socbay/blocs/staff/new_task_sale/staff_service_screen_sale_state.dart';
import 'package:socbay/blocs/tab_bar/tab_bar_bloc.dart';
import 'package:socbay/blocs/tab_bar/tab_bar_event.dart';
import 'package:socbay/blocs/task/task_screen_bloc.dart';
import 'package:socbay/blocs/task/task_screen_event.dart';
import 'package:socbay/config/app_config.dart';
import 'package:socbay/data/model/home_service_model.dart';
import 'package:socbay/data/model/machine_model.dart';
import 'package:socbay/data/model/order_model.dart';
import 'package:socbay/data/model/product_model.dart';
import 'package:socbay/data/model/request/create_task_request.dart';
import 'package:socbay/data/model/request/user_address_request.dart';
import 'package:socbay/data/model/user_profile.dart';
import 'package:socbay/routes.dart';
import 'package:socbay/screens/staff/technique/technique_screen.dart';
import 'package:socbay/utils/color_util.dart';
import 'package:socbay/utils/context_extension.dart';
import 'package:socbay/utils/date_util.dart';
import 'package:socbay/utils/file_util.dart';
import 'package:socbay/utils/image_util.dart';
import 'package:socbay/widgets/button_widget.dart';
import 'package:socbay/widgets/dialog/custom_alert_dialog.dart';
import 'package:socbay/widgets/loading_indicator.dart';
import 'package:socbay/widgets/my_app_bar.dart';
import 'package:socbay/widgets/text_field_default.dart';
import 'package:image/image.dart' as img;

class StaffServiceSaleScreen extends StatefulWidget {
  const StaffServiceSaleScreen({super.key});

  @override
  State<StatefulWidget> createState() => _StaffServiceSaleScreenState();
}

class _StaffServiceSaleScreenState extends State<StaffServiceSaleScreen> {
  late StaffServiceSaleScreenBloc _bloc;

  late TextEditingController staffFavoriteTxtController;
  late TextEditingController describeRequestTxtController;
  late TextEditingController addressRequestTxtController;
  late TextEditingController _nameTextController;
  late TextEditingController addressSPRequestTxtController;
  late TextEditingController _addressTextController;

  location_dart.LocationData? locationData;

  String _currentText = '';
  List<HomeServiceModel> _listService = [];
  final List<OrderModel> _listProducts = [];
  final List<String> _listPath = [];
  String? _currentSelectedValue;
  int _currentSelectedProductValue = 0;
  String _dateStart = '';
  String _timeStart = '';
  UserProfile? _favouriteStaff;

  bool _addNewCustomer = false;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  late final ImagePicker _picker;
  final customerController = TextEditingController();
  late TabBarBloc _tabBarBloc;

  @override
  void initState() {
    _bloc = BlocProvider.of(context);
    _tabBarBloc = BlocProvider.of<TabBarBloc>(context);
    staffFavoriteTxtController = TextEditingController();
    describeRequestTxtController = TextEditingController();
    _nameTextController = TextEditingController();
    _addressTextController = TextEditingController();
    addressRequestTxtController = TextEditingController();
    addressSPRequestTxtController = TextEditingController();
    _listService = HomeServiceModel.taskServiceList;
    _listProducts.add(
      OrderModel(
        id: 0,
        product: MachineModel(id: 0, name: "--Chọn máy--"),
        proad: ProductModel(address: "--Chọn máy--"),
      ),
    );
    _currentSelectedValue = _listService[int.tryParse(_bloc.args['index']) ?? 0]
        .id
        .toString();
    _picker = ImagePicker();

    if (selectedDate != null) {
      setState(() {
        _dateStart = selectedDate!.toDateString(format: 'dd/MM/yyyy');
      });
    } else {
      setState(() {
        _dateStart = DateTime.now().toDateString(format: 'dd/MM/yyyy');
      });
    }
    if (selectedTime != null) {
      setState(() {
        _timeStart = selectedTime!.toTimeString();
      });
    } else {
      setState(() {
        _timeStart = DateFormat('HH:mm').format(DateTime.now());
      });
    }
    if (_bloc.args.containsKey('phone')) {
      customerController.text = _bloc.args['phone'];
      _onSearchCustomer();
    }
    customerController.addListener(_onSearchCustomer);
    super.initState();
  }

  @override
  void dispose() {
    staffFavoriteTxtController.dispose();
    describeRequestTxtController.dispose();
    addressRequestTxtController.dispose();
    _nameTextController.dispose();
    _addressTextController.dispose();
    customerController.dispose();
    addressSPRequestTxtController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<
      StaffServiceSaleScreenBloc,
      StaffServiceSaleScreenState
    >(builder: _builder, listener: _listener);
  }

  void _listener(BuildContext context, StaffServiceSaleScreenState state) {
    if (state is StaffServiceScreenSaleCheckCustomerSuccessState) {
      _listProducts.clear();
      _listProducts.add(
        OrderModel(
          id: 0,
          product: MachineModel(id: 0, name: "--Chọn máy--"),
          proad: ProductModel(address: "chọn máy"),
        ),
      );
      for (var element in _bloc.listProducts) {
        if (element.product != null) {
          _listProducts.add(element);
        }
      }
      setState(() {
        _addNewCustomer = false;
        customerController.text = _bloc.customerInfo?.username ?? '';
      });
    }
    if (state is StaffServiceScreenSaleCheckCustomerFailedState) {
      setState(() {
        _addNewCustomer = true;
      });
    }

    if (state is StaffServiceScreenSaleChangeTypeServiceState) {
      _currentSelectedValue = state.typeService;
    }

    if (state is StaffServiceScreenSaleCreateTaskSuccessState) {
      CustomAlertDialog.show(
        context,
        content: "Đăng ký dịch vụ thành công",
        leftText: "Ok",
        isLeftPositive: true,
        backListener: () {},
        isShowTitle: false,
        leftAction: () async {
          _tabBarBloc.add(const TabBarPressed(index: 1));
          Navigator.pushReplacementNamed(context, Routes.root).then(
            (value) => context.read<TaskScreenBloc>().add(
              const StaffTaskScreenGetTaskByDayEvent(isRefresh: true),
            ),
          );
        },
      );
    }

    if (state is StaffServiceScreenSaleCreateTaskFailedState) {
      context.showSnackBar(state.message);
    }

    if (state is StaffServiceScreenSaleUploadImageSuccessState) {
      for (var element in state.paths) {
        setState(() {
          _listPath.add(element);
        });
      }
    }
    if (state is UserAddressScreenSaleCreateAddressSuccessState) {
      context.showSnackBar('Thêm khách hàng thành công!');
      setState(() {
        _addNewCustomer = false;
        _currentText = '';
        _onSearchCustomer();
      });
    }
    if (state is UserAddressScreenSaleCreateAddressFailState) {
      context.showSnackBar('Thêm khách hàng thất bại!');
    }
  }

  // ─── helpers ───────────────────────────────────────────────────────────────

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16.0),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ColorUtil.bangladeshGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: ColorUtil.bangladeshGreen, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: ColorUtil.raisinBlack,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── builder ───────────────────────────────────────────────────────────────

  Widget _builder(BuildContext context, StaffServiceSaleScreenState state) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: MyAppBar(
        isBackNavigation: true,
        title: 'Tạo công việc',
        centerTitle: true,
        onBack: () => Navigator.pop(context),
      ),
      body: LoadingIndicator(
        isLoading: _bloc.isLoading,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildCardServiceAndCustomer(),
                const SizedBox(height: 16),
                _buildCardScheduling(),
                const SizedBox(height: 16),
                _buildCardStaffAndRequest(),
                const SizedBox(height: 16),
                _buildCardMedia(),
                const SizedBox(height: 32),
                _buildBookingButton(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── card 1: dịch vụ, khách hàng, máy ─────────────────────────────────────

  Widget _buildCardServiceAndCustomer() {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            '1. Thông tin dịch vụ & Khách hàng',
            Icons.home_repair_service_rounded,
          ),
          _buildDropdownField(),
          const SizedBox(height: 16),
          _buildSearchCustomer(),
          const SizedBox(height: 16),
          _buildDropdownFieldPruducts(),
        ],
      ),
    );
  }

  Widget _buildDropdownField() {
    final hasValue = _listService.any(
      (e) => e.id.toString() == _currentSelectedValue,
    );
    return DropdownButtonFormField<String>(
      value: hasValue ? _currentSelectedValue : null,
      decoration: InputDecoration(
        labelText: 'Loại dịch vụ',
        labelStyle: TextStyle(
          color: ColorUtil.bangladeshGreen.withValues(alpha: 0.8),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        prefixIcon: const Icon(
          Icons.construction_rounded,
          color: ColorUtil.bangladeshGreen,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: ColorUtil.bangladeshGreen,
            width: 1.5,
          ),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      isExpanded: true,
      hint: const Text(
        'Chọn loại dịch vụ',
        style: TextStyle(color: ColorUtil.silverChalice, fontSize: 14),
      ),
      icon: const Icon(
        Icons.arrow_drop_down_rounded,
        color: ColorUtil.spanishGray,
        size: 28,
      ),
      onChanged: (String? newValue) {
        if (newValue != null) {
          _bloc.add(StaffServiceScreenSaleChangeTypeServiceEvent(newValue));
        }
      },
      items: _listService.map((HomeServiceModel sv) {
        return DropdownMenuItem<String>(
          value: sv.id.toString(),
          child: Text(
            sv.name ?? '',
            style: const TextStyle(fontSize: 14, color: ColorUtil.raisinBlack),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSearchCustomer() {
    if (_addNewCustomer) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.number,
                  controller: customerController,
                  style: const TextStyle(
                    color: ColorUtil.raisinBlack,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    labelText: 'SĐT Khách hàng',
                    labelStyle: TextStyle(
                      color: ColorUtil.bangladeshGreen.withValues(alpha: 0.8),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    prefixIcon: const Icon(
                      Icons.phone_outlined,
                      color: ColorUtil.bangladeshGreen,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.grey.shade200,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: ColorUtil.bangladeshGreen,
                        width: 1.5,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _addCustomer,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: ColorUtil.brightYellow,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: ColorUtil.brightYellow.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person_add_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Không tìm thấy khách hàng. Nhấn + để thêm mới.',
            style: TextStyle(color: ColorUtil.brightYellow, fontSize: 12),
          ),
        ],
      );
    } else {
      return TextField(
        keyboardType: TextInputType.number,
        controller: customerController,
        style: const TextStyle(color: ColorUtil.raisinBlack, fontSize: 14),
        decoration: InputDecoration(
          labelText: 'SĐT Khách hàng',
          labelStyle: TextStyle(
            color: ColorUtil.bangladeshGreen.withValues(alpha: 0.8),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          prefixIcon: const Icon(
            Icons.phone_outlined,
            color: ColorUtil.bangladeshGreen,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: ColorUtil.bangladeshGreen,
              width: 1.5,
            ),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      );
    }
  }

  Widget _buildDropdownFieldPruducts() {
    final hasProduct = _listProducts.any(
      (e) => e.id == _currentSelectedProductValue,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: hasProduct ? _currentSelectedProductValue.toString() : null,
          decoration: InputDecoration(
            labelText: 'Chọn máy / thiết bị',
            labelStyle: TextStyle(
              color: ColorUtil.bangladeshGreen.withValues(alpha: 0.8),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            prefixIcon: const Icon(
              Icons.devices_other_rounded,
              color: ColorUtil.bangladeshGreen,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: ColorUtil.bangladeshGreen,
                width: 1.5,
              ),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          isExpanded: true,
          icon: const Icon(
            Icons.arrow_drop_down_rounded,
            color: ColorUtil.spanishGray,
            size: 28,
          ),
          onChanged: (String? newValue) {
            setState(() {
              _currentSelectedProductValue = int.parse(newValue ?? '0');
              final matched = _listProducts.where(
                (item) =>
                    item.id.toString() ==
                    _currentSelectedProductValue.toString(),
              );
              if (matched.isNotEmpty) {
                addressSPRequestTxtController.text =
                    matched.first.address ?? '';
              }
            });
          },
          items: _listProducts.map((OrderModel sv) {
            return DropdownMenuItem<String>(
              value: sv.id.toString(),
              child: Text(
                sv.product?.name ?? '',
                style: const TextStyle(
                  fontSize: 14,
                  color: ColorUtil.raisinBlack,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: addressSPRequestTxtController,
          maxLines: 2,
          cursorColor: ColorUtil.bangladeshGreen,
          style: const TextStyle(fontSize: 14, color: ColorUtil.raisinBlack),
          decoration: InputDecoration(
            labelText: 'Vị trí lắp đặt chi tiết',
            labelStyle: TextStyle(
              color: ColorUtil.bangladeshGreen.withValues(alpha: 0.8),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            prefixIcon: const Icon(
              Icons.location_on_outlined,
              color: ColorUtil.bangladeshGreen,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: ColorUtil.bangladeshGreen,
                width: 1.5,
              ),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            hintText: 'Nhập vị trí lắp đặt chi tiết...',
            hintStyle: const TextStyle(
              color: ColorUtil.silverChalice,
              fontSize: 13,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  // ─── card 2: lịch hẹn ──────────────────────────────────────────────────────

  Widget _buildCardScheduling() {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            '2. Thời gian hẹn lịch',
            Icons.calendar_month_rounded,
          ),
          Row(
            children: [
              Expanded(
                child: _buildPickerTile(
                  title: 'Ngày thực hiện',
                  value: _dateStart.isEmpty ? 'Chọn ngày' : _dateStart,
                  icon: Icons.calendar_today_rounded,
                  onTap: _onTapDateStart,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPickerTile(
                  title: 'Giờ bắt đầu',
                  value: _timeStart.isEmpty ? 'Chọn giờ' : _timeStart,
                  icon: Icons.access_time_rounded,
                  onTap: _onTapTimeStart,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPickerTile({
    required String title,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final hasValue =
        value != 'Chọn ngày' && value != 'Chọn giờ' && value.isNotEmpty;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasValue
                ? ColorUtil.bangladeshGreen.withValues(alpha: 0.3)
                : Colors.grey.shade200,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: hasValue
                  ? ColorUtil.bangladeshGreen
                  : ColorUtil.spanishGray,
              size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: ColorUtil.spanishGray,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      color: hasValue
                          ? ColorUtil.raisinBlack
                          : ColorUtil.silverChalice,
                      fontSize: 14,
                      fontWeight: hasValue
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── card 3: thợ ưa thích & mô tả ─────────────────────────────────────────
  // Sale screen always shows favourite staff selector (no role check needed)

  Widget _buildCardStaffAndRequest() {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            '3. Kỹ thuật viên & Nội dung yêu cầu',
            Icons.person_pin_rounded,
          ),
          _buildFavoriteStaffSelector(),
          const SizedBox(height: 16),
          _buildFormDescribe(
            'Nhập chi tiết mô tả yêu cầu công việc hoặc lưu ý đặc biệt tại đây...',
            describeRequestTxtController,
            Icons.edit_note_rounded,
            null,
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteStaffSelector() {
    if (_favouriteStaff == null) {
      return InkWell(
        onTap: _onChooseFavouriteStaff,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200, width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ColorUtil.bangladeshGreen.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_add_alt_1_rounded,
                  color: ColorUtil.bangladeshGreen,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kỹ thuật viên ưa thích',
                      style: TextStyle(
                        color: ColorUtil.raisinBlack,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Nhấn để chọn kỹ thuật viên yêu thích (Tùy chọn)',
                      style: TextStyle(
                        color: ColorUtil.spanishGray,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: ColorUtil.spanishGray,
                size: 16,
              ),
            ],
          ),
        ),
      );
    }

    final initial = _favouriteStaff?.username?.isNotEmpty == true
        ? _favouriteStaff!.username![0].toUpperCase()
        : 'S';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorUtil.bangladeshGreen, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: ColorUtil.bangladeshGreen.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: ColorUtil.bangladeshGreen,
            child: Text(
              initial,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _favouriteStaff?.username ?? '',
                  style: const TextStyle(
                    color: ColorUtil.raisinBlack,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Kỹ thuật viên yêu thích',
                  style: TextStyle(
                    color: ColorUtil.bangladeshGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.close_rounded,
              color: ColorUtil.spanishGray,
              size: 20,
            ),
            onPressed: () => setState(() => _favouriteStaff = null),
          ),
        ],
      ),
    );
  }

  Widget _buildFormDescribe(
    String placeHolder,
    TextEditingController controller,
    IconData iconPrefix,
    IconData? iconSuffix, {
    bool isReadOnly = false,
    bool haveSuffixIcon = false,
  }) {
    return TextFormField(
      readOnly: isReadOnly,
      keyboardType: TextInputType.multiline,
      controller: controller,
      maxLines: 4,
      cursorColor: ColorUtil.bangladeshGreen,
      style: const TextStyle(fontSize: 14, color: ColorUtil.raisinBlack),
      decoration: InputDecoration(
        labelText: 'Mô tả chi tiết yêu cầu',
        labelStyle: TextStyle(
          color: ColorUtil.bangladeshGreen.withValues(alpha: 0.8),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        alignLabelWithHint: true,
        filled: true,
        fillColor: Colors.grey.shade50,
        prefixIcon: Padding(
          padding: const EdgeInsets.only(bottom: 50.0),
          child: Icon(iconPrefix, color: ColorUtil.bangladeshGreen),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: ColorUtil.bangladeshGreen,
            width: 1.5,
          ),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        hintText: placeHolder,
        hintStyle: const TextStyle(
          color: ColorUtil.silverChalice,
          fontSize: 13,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  // ─── card 4: hình ảnh ──────────────────────────────────────────────────────

  Widget _buildCardMedia() {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            '4. Hình ảnh minh họa',
            Icons.photo_library_rounded,
          ),
          const Text(
            'Tải lên tối đa 4 ảnh chụp thực tế vị trí hoặc thiết bị để kỹ thuật viên chuẩn bị chu đáo nhất.',
            style: TextStyle(
              color: ColorUtil.graniteGray,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 110,
            child: ListView.builder(
              itemCount: _listPath.length < 4 ? _listPath.length + 1 : 4,
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) {
                if (index == _listPath.length && _listPath.length < 4) {
                  return _buildDefaultItemMedia();
                }
                return _buildItemMedia(_listPath[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultItemMedia() {
    return GestureDetector(
      onTap: _showModalBottomSheetMedia,
      child: Container(
        width: 100,
        height: 100,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: ColorUtil.bangladeshGreen.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_a_photo_outlined,
              color: ColorUtil.bangladeshGreen,
              size: 24,
            ),
            SizedBox(height: 6),
            Text(
              'Tải ảnh lên',
              style: TextStyle(
                color: ColorUtil.bangladeshGreen,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemMedia(String path) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      width: 100,
      height: 100,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: ImageUtil.loadNetWorkImage(
              url: "$protocol${AppConfig.instance.values.apiUrl}$path",
              width: 100,
              height: 100,
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => setState(() => _listPath.remove(path)),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── nút đặt lịch ──────────────────────────────────────────────────────────

  Widget _buildBookingButton() {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        color: ColorUtil.bangladeshGreen,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ColorUtil.bangladeshGreen.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _onCreateTask,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_outline_rounded,
                color: Colors.white,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'ĐẶT LỊCH NGAY',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── business logic ────────────────────────────────────────────────────────

  Future _onCreateTask() async {
    if (_currentSelectedValue == "") {
      context.showSnackBar("Vui lòng chọn loại dịch vụ!");
      return;
    }
    if (_dateStart.isEmpty || _timeStart.isEmpty) {
      context.showSnackBar("Vui lòng chọn ngày và giờ bắt đầu!");
      return;
    }
    String? serviceName;
    for (var i in _listService) {
      if (i.id == int.parse(_currentSelectedValue ?? "1")) {
        serviceName = i.name;
      }
    }
    _bloc.add(
      StaffServiceScreenSaleCreateTaskEvent(
        CreateTaskRequest(
          type: 1,
          name: serviceName,
          des: describeRequestTxtController.text,
          status: _favouriteStaff?.id == null ? 1 : 5,
          priority: 1,
          serviceId: int.parse(_currentSelectedValue ?? "1"),
          timeStart: '$_dateStart $_timeStart',
          timeEnd: '',
          staffId: _favouriteStaff?.id,
          customerId: _bloc.customerInfo?.id ?? 0,
          video: '',
          address: addressSPRequestTxtController.text,
          productId: _currentSelectedProductValue,
          images: _listPath,
        ),
        false,
      ),
    );
  }

  void _onTapDateStart() => _selectDate();
  void _onTapTimeStart() => _selectTime();

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      locale: const Locale("vi", "VN"),
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2050),
    );
    if (picked != null && picked != selectedDate) {
      selectedDate = picked;
      setState(() {
        _dateStart = selectedDate!.toDateString(format: "dd/MM/yyyy");
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != selectedTime) {
      selectedTime = picked;
      setState(() {
        final hour = picked.hour.toString().padLeft(2, "0");
        final minute = picked.minute.toString().padLeft(2, "0");
        _timeStart = "$hour:$minute";
      });
    }
  }

  void _onSearchCustomer() {
    if (customerController.text.isNotEmpty &&
        customerController.text.length == 10 &&
        customerController.text != _currentText &&
        isValidPhoneNumber(customerController.text)) {
      _currentText = customerController.text;
      _bloc.add(
        StaffServiceSaleScreenCheckCustomerEvent(customerController.text),
      );
    }
  }

  // ─── dialog: thêm khách hàng mới ───────────────────────────────────────────

  Future<void> _addCustomer() async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          scrollable: true,
          title: const Text('Thêm mới khách hàng', textAlign: TextAlign.center),
          content: Column(
            children: [
              _buildTextField(
                controller: _nameTextController,
                hintText: 'Họ và tên',
              ),
              _buildTextField(
                controller: _addressTextController,
                hintText: 'Địa chỉ',
              ),
              _buildTextField(
                controller: customerController,
                hintText: 'Số điện thoại',
                isPhoneNumber: true,
              ),
            ],
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildButtonDialog(
                  isPositive: false,
                  text: 'Hủy',
                  action: () => Navigator.pop(context),
                ),
                const SizedBox(width: 16),
                _buildButtonDialog(
                  isPositive: true,
                  text: 'Gửi',
                  action: () {
                    _bloc.add(
                      UserAddressScreenSaleCreateUserAddressEvent(
                        UserAddressRequest(
                          name: _nameTextController.text.trim(),
                          phone: customerController.text.trim(),
                          address: _addressTextController.text.trim(),
                          pass: customerController.text.trim(),
                          cityCode: "AGG",
                          stateCode: "dt",
                        ),
                      ),
                    );
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildButtonDialog({isPositive, action, text}) {
    return Expanded(child: _button(isPositive, action, text));
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool isPhoneNumber = false,
  }) {
    return GestureDetector(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: TextFieldDefault(
          enabled: !isPhoneNumber,
          controller: controller,
          onChanged: (String text) => setState(() {}),
          keyboardType: isPhoneNumber
              ? TextInputType.phone
              : TextInputType.text,
          maxLength: isPhoneNumber ? 10 : null,
          hintText: hintText,
          label: Text(hintText),
        ),
      ),
    );
  }

  StatelessWidget _button(isPositive, action, text) {
    return ButtonWidget(
      color: isPositive ? ColorUtil.bangladeshGreen : Colors.grey,
      borderRadius: BorderRadius.circular(30),
      padding: const EdgeInsets.symmetric(vertical: 10),
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
        style: const TextStyle(fontSize: 16, color: Colors.white),
      ),
    );
  }

  void _onChooseFavouriteStaff() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => TechniqueScreen(
              initialTabIndex: 1,
              favoriteStaff: _favouriteStaff,
            ),
          ),
        )
        .then((value) {
          Map<String, dynamic>? result = {};
          result = value as Map<String, dynamic>?;
          if (result != null) {
            setState(() {
              _favouriteStaff = result!['favouriteStaff'];
            });
          }
        });
  }

  void _showModalBottomSheetMedia() {
    showModalBottomSheet(
      useSafeArea: true,
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Image'),
              onTap: _onChooseImages,
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Camera'),
              onTap: () {
                getImage(ImageSource.camera);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _onChooseImages() async {
    Navigator.of(context).pop();
    List<File>? files = await onGetMultiPhoto(
      context: context,
      funcPermission: () {},
      picker: _picker,
    );
    if (files != null && files.isNotEmpty) {
      for (var file in files) {
        img.Image? originalImage = img.decodeImage(await file.readAsBytes());
        img.Image filesImg = img.copyResize(originalImage!, width: 500);
        await File(file.path).writeAsBytes(img.encodePng(filesImg));
      }
      if (_listPath.length + files.length <= 4) {
        _bloc.add(StaffServiceScreenSaleUploadImageEvent(files));
      } else {
        context.showSnackBar('Chỉ được chọn tối đa 4 ảnh!');
        return;
      }
    }
  }

  Future getImage(ImageSource imgSource) async {
    if (await Permission.camera.request().isGranted) {
      if (_listPath.length >= 4) {
        context.showSnackBar('Chỉ được chọn tối đa 4 ảnh!');
        return;
      } else {
        final picker = ImagePicker();
        File? galleryFile;
        final pickedFile = await picker.pickImage(
          source: imgSource,
          imageQuality: 30,
        );
        List<File>? files = [];
        if (pickedFile != null) {
          galleryFile = File(pickedFile.path);
          files.add(galleryFile);
          if (_listPath.length + files.length <= 4) {
            _bloc.add(StaffServiceScreenSaleUploadImageEvent(files));
          } else {
            context.showSnackBar('Chỉ được chọn tối đa 4 ảnh!');
          }
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Nothing is selected')));
        }
      }
    } else {
      CustomAlertDialog.show(
        context,
        leftText: "Cài đặt",
        rightText: "Hủy",
        isLeftPositive: true,
        leftAction: () {
          Navigator.pop(context);
          openAppSettings();
        },
        content: 'Vui lòng cấp quyền truy cập camera.',
      );
    }
  }

  bool isValidPhoneNumber(String string) {
    if (string.isEmpty) return false;
    const pattern = r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$';
    final regExp = RegExp(pattern);
    if (!regExp.hasMatch(string)) return false;
    return true;
  }
}
