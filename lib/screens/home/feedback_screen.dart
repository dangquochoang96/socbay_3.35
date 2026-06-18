import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:socbay/blocs/home/feedback/feedback_screen_bloc.dart';
import 'package:socbay/blocs/home/feedback/feedback_screen_event.dart';
import 'package:socbay/blocs/home/feedback/feedback_screen_state.dart';
import 'package:socbay/config/app_config.dart';
import 'package:socbay/constants/constants.dart';
import 'package:socbay/data/model/order_filter_core_model.dart';
import 'package:socbay/routes.dart';
import 'package:socbay/utils/color_util.dart';
import 'package:socbay/utils/context_extension.dart';
import 'package:socbay/utils/file_util.dart';
import 'package:socbay/utils/image_util.dart';
import 'package:socbay/widgets/button_widget.dart';
import 'package:socbay/widgets/dialog/custom_alert_dialog.dart';
import 'package:socbay/widgets/loading_indicator.dart';
import 'package:socbay/widgets/my_app_bar.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen>
    with TickerProviderStateMixin {
  late FeedbackScreenBloc _bloc;
  late TabController _tabController;
  late TextEditingController describeRequestTxtController;
  late final ImagePicker _picker;
  final List<String> _listFile = [];
  final List<OrderFilterCoreModel> _listOrders = [];
  String? _selectedValue;
  int page = 0;

  @override
  void initState() {
    _bloc = BlocProvider.of(context);
    _tabController = TabController(length: 2, initialIndex: 0, vsync: this);
    if (_tabController.index == 0) {
      _bloc.add(FeedbackScreenTabPressEvent(_tabController.index));
    }
    _tabController.addListener(() {
      if (_tabController.index != _tabController.previousIndex) {
        _bloc.add(FeedbackScreenTabPressEvent(_tabController.index));
      }
    });

    describeRequestTxtController = TextEditingController();
    _picker = ImagePicker();
    super.initState();
  }

  @override
  void dispose() {
    _bloc.close();
    _tabController.dispose();
    describeRequestTxtController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FeedbackScreenBloc, FeedbackScreenState>(
      builder: _builder,
      listener: _listener,
    );
  }

  void _listener(BuildContext context, FeedbackScreenState state) {
    if (state is FeedbackScreenChangeTabState) {
      setState(() {
        if (state.index == 0) {
          _listOrders.clear();
          _listOrders.add(OrderFilterCoreModel(id: 0, name: "--Chọn--"));
          _listOrders.addAll(_bloc.ordersModel);
          _selectedValue = _bloc.currentOrderId.toString();
          describeRequestTxtController.clear();
        } else {
          _tabController.index = 1;
        }
      });
    }
    if (state is FeedbackUploadImagesSuccessState) {
      for (var element in state.paths) {
        _listFile.add(element);
      }
    }
    if (state is FeedbackCreateSuccessState) {
      context.showSnackBar("Phản hồi thành công!");
    }
    if (state is FeedbackCreateErrorState) {
      context.showSnackBar("Phản hồi không thành công!");
    }
  }

  Widget _builder(BuildContext context, FeedbackScreenState state) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: MyAppBar(
        isBackNavigation: true,
        title: 'Góp ý và khiếu nại',
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              indicatorColor: ColorUtil.bangladeshGreen,
              labelColor: ColorUtil.bangladeshGreen,
              unselectedLabelColor: Colors.grey,
              labelStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              tabs: const [
                Tab(height: 48, text: 'Tạo mới'),
                Tab(height: 48, text: 'Đã gửi'),
              ],
            ),
          ),
          Expanded(
            child: IndexedStack(
              index: _tabController.index,
              children: [_buildCreateFeedback(), _buildListFeedback()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateFeedback() {
    return LoadingIndicator(
      isLoading: _bloc.isLoading,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCard(
            title: "Thông tin phản hồi",
            icon: Icons.feedback_outlined,
            child: Column(
              children: [
                _buildField(
                  Icons.report_problem_outlined,
                  null,
                  value: "Góp ý và khiếu nại",
                  onTap: () {},
                ),
                const SizedBox(height: 16),
                _buildDropdownFieldOrders(),
                const SizedBox(height: 16),
                _buildFormDescribe(
                  'Mô tả chi tiết yêu cầu của bạn...',
                  describeRequestTxtController,
                  Icons.description_outlined,
                  null,
                ),
              ],
            ),
          ),
          _buildCard(
            title: "Hình ảnh / Video đính kèm",
            icon: Icons.attach_file_outlined,
            child: _buildSectionMedia(),
          ),
          const SizedBox(height: 16),
          _button(true, () {
            _onCreateFeedBack();
          }, 'GỬI PHẢN HỒI'),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Future _onCreateFeedBack() async {
    if (_selectedValue == null || _selectedValue!.trim() == "0") {
      context.showSnackBar("Đơn hàng không hợp lệ!");
      return;
    }
    _bloc.add(
      FeedbackCreateEvent(
        orderId: _selectedValue ?? "",
        description: describeRequestTxtController.text,
        images: _listFile,
      ),
    );
  }

  Widget _buildListFeedback() {
    if (_bloc.feedBacksModel.isNotEmpty) {
      return LoadingIndicator(
        isLoading: _bloc.isLoading,
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemBuilder: _buildItemServiceHistory,
          separatorBuilder: separatorBuilder,
          itemCount: _bloc.feedBacksModel.length,
        ),
      );
    }
    return const Center(
      child: Text(
        'Chưa có dữ liệu phản hồi',
        style: TextStyle(color: Colors.grey, fontSize: 16),
      ),
    );
  }

  Widget _buildItemServiceHistory(BuildContext context, int index) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          Routes.detailFeedBackScreen,
          arguments: {
            "fbId": _bloc.feedBacksModel[index].id.toString(),
            "orderId": "0",
          },
        );
      },
      child: Container(
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
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: ColorUtil.bangladeshGreen.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.receipt_long_outlined,
                    color: ColorUtil.bangladeshGreen,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Mã đơn: ĐH_${_bloc.feedBacksModel[index].orderId}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: ColorUtil.bangladeshGreen,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildInfoRow(
                    "Trạng thái:",
                    _bloc.feedBacksModel[index].getStatus(),
                    valueColor:
                        _bloc.feedBacksModel[index].getStatus() == "Đã xử lý"
                        ? ColorUtil.bangladeshGreen
                        : ColorUtil.brightYellow,
                    isBold: true,
                  ),
                  _buildInfoRow(
                    "Mô tả:",
                    _bloc.feedBacksModel[index].description ?? 'Không có mô tả',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget separatorBuilder(BuildContext context, int index) {
    return const SizedBox(height: 16);
  }

  Widget _button(bool isPositive, Function()? action, String text) {
    return ButtonWidget(
      color: isPositive ? ColorUtil.bangladeshGreen : Colors.grey,
      borderRadius: BorderRadius.circular(30),
      padding: const EdgeInsets.symmetric(vertical: 14),
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
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildField(
    IconData iconPrefix,
    IconData? iconSuffix, {
    required String value,
    required void Function() onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.grey.shade300),
          color: Colors.grey.shade50,
        ),
        child: Row(
          children: [
            Icon(iconPrefix, color: ColorUtil.bangladeshGreen, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  color: value.isEmpty ? Colors.grey : ColorUtil.raisinBlack,
                  fontSize: 15,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (iconSuffix != null)
              Icon(iconSuffix, color: Colors.grey, size: 20),
          ],
        ),
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
      maxLines: 5,
      cursorColor: ColorUtil.bangladeshGreen,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        prefixIcon: Padding(
          padding: const EdgeInsets.only(bottom: 80.0),
          child: Icon(iconPrefix, color: ColorUtil.bangladeshGreen, size: 20),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: ColorUtil.bangladeshGreen),
        ),
        hintText: placeHolder,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
      ),
    );
  }

  Widget _buildSectionMedia() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Icon(Icons.info_outline, color: ColorUtil.spanishGray, size: 16),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Up ảnh (tối đa 4 ảnh) và video (tối đa 15s) để kỹ thuật xem xét.',
                style: TextStyle(color: ColorUtil.spanishGray, fontSize: 13),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          width: double.infinity,
          child: ListView.builder(
            itemCount: _listFile.length + 1,
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemBuilder: (BuildContext context, int index) {
              return index < _listFile.length
                  ? _buildItemMedia(_listFile[index])
                  : _buildDefaultItemMedia();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultItemMedia() {
    return GestureDetector(
      onTap: _showModalBottomSheetMedia,
      child: Container(
        height: 100,
        width: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.grey.shade300),
          color: Colors.grey.shade50,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.add_photo_alternate_outlined,
              color: Colors.grey,
              size: 30,
            ),
            SizedBox(height: 4),
            Text(
              'Thêm ảnh',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
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

  Widget _buildItemMedia(String path) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
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
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
              onTap: () {
                setState(() {
                  _listFile.remove(path);
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownFieldOrders() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedValue,
          isDense: true,
          isExpanded: true,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
          onChanged: (String? newValue) {
            setState(() {
              _selectedValue = newValue;
            });
          },
          items: _listOrders.map((OrderFilterCoreModel sv) {
            return DropdownMenuItem<String>(
              value: sv.id.toString(),
              child: Row(
                children: [
                  const Icon(
                    Icons.receipt_outlined,
                    color: ColorUtil.bangladeshGreen,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      sv.id == 0
                          ? "-- Chọn đơn hàng --"
                          : "${sv.product} - ${_createdDateConvert(sv.createdAt)}: Mã đơn ${sv.id}",
                      style: const TextStyle(fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
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

  String _createdDateConvert(String? dateTime) {
    if (dateTime == null) {
      return "";
    }
    return dateTime.substring(0, 10);
  }

  // void _onChooseMedia() async {
  //   File? file = await onGetPhotoFromGallery(
  //       context: context, funcPermission: () {}, picker: _picker);
  //   if (file != null) {
  //     setState(() {
  //       if (_listFile.length < 4) {
  //         _listFile.add(file);
  //       } else {
  //         context.showSnackBar('Chỉ được chọn tối đa 4 ảnh!');
  //         return;
  //       }
  //     });
  //   }
  // }
  void _onChooseImages() async {
    Navigator.of(context).pop();
    List<File>? files = await onGetMultiPhoto(
      context: context,
      funcPermission: () {},
      picker: _picker,
    );
    if (files != null && files.isNotEmpty) {
      if ((_listFile.length + files.length) <= 4) {
        _bloc.add(UploadImageEvent(files));
      } else {
        context.showSnackBar('Chỉ được chọn tối đa 4 ảnh!');
        return;
      }
    }
  }

  Future getImage(ImageSource img) async {
    if (await Permission.camera.request().isGranted) {
      if (_listFile.length >= 4) {
        context.showSnackBar('Chỉ được chọn tối đa 4 ảnh!');
        return;
      } else {
        final picker = ImagePicker();
        File? galleryFile;
        final pickedFile = await picker.pickImage(
          source: img,
          imageQuality: 30,
        );
        List<File>? files = [];
        if (pickedFile != null) {
          galleryFile = File(pickedFile.path);
          files.add(galleryFile);
          _bloc.add(UploadImageEvent(files));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            // is this context <<<
            const SnackBar(content: Text('Nothing is selected')),
          );
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
}
