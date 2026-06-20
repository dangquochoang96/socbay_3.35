import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path_manager;
import 'package:socbay/application.dart';
import 'package:socbay/blocs/retail_order/retail_order_bloc.dart';
import 'package:socbay/blocs/retail_order/retail_order_event.dart';
import 'package:socbay/blocs/retail_order/retail_order_state.dart';
import 'package:socbay/config/app_config.dart';
import 'package:socbay/constants/constants.dart';
import 'package:socbay/data/model/retail_order_model.dart';
import 'package:socbay/data/model/retail_warehouse_model.dart';
import 'package:socbay/utils/color_util.dart';
import 'package:socbay/utils/image_util.dart';
import 'package:socbay/widgets/my_app_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:socbay/screens/retailOrder/create_retail_order.dart';

class RetailOrderScreen extends StatefulWidget {
  const RetailOrderScreen({super.key});

  @override
  State<RetailOrderScreen> createState() => _RetailOrderScreenState();
}

class _RetailOrderScreenState extends State<RetailOrderScreen> {
  late RetailOrderBloc _bloc;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = "";
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _bloc = BlocProvider.of<RetailOrderBloc>(context);
    _bloc.add(const FetchRetailOrdersEvent(isRefresh: true));
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _bloc.add(FetchRetailOrdersEvent(isRefresh: false, search: _searchQuery));
    }
  }

  void _onSearchChanged(String val) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () {
      setState(() {
        _searchQuery = val;
      });
      _bloc.add(FetchRetailOrdersEvent(isRefresh: true, search: val));
    });
  }

  void _onRefresh() {
    _bloc.add(FetchRetailOrdersEvent(isRefresh: true, search: _searchQuery));
  }

  String _formatCurrency(dynamic val) {
    if (val == null) return '0 đ';
    try {
      double value = 0;
      if (val is String) {
        value = double.tryParse(val) ?? 0;
      } else if (val is num) {
        value = val.toDouble();
      }
      final formatter = NumberFormat.currency(
        locale: 'vi_VN',
        symbol: 'đ',
        decimalDigits: 0,
      );
      return formatter.format(value);
    } catch (e) {
      return '$val đ';
    }
  }

  String _formatDatetime(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) {
      return 'Chưa xác định';
    }
    try {
      DateTime getDateTime = DateTime.parse(dateTimeString);
      return DateFormat('dd/MM/yyyy HH:mm').format(getDateTime);
    } catch (ex) {
      return dateTimeString;
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case '5': // Đã giao thành công
        return const Color(0xff4caf50);
      case '-1': // Đã hủy
      case '6': // Giao hàng thất bại
      case '7': // Hủy trong SX
      case '8': // Hủy trong ĐG
      case '9': // Hủy trong Ship
        return ColorUtil.red;
      case '0': // Chưa xác nhận
        return const Color(0xffFF9800);
      case '1': // Đã xác nhận
      case '2': // Đang đóng hàng
      case '3': // Đang chuẩn bị giao
      case '4': // Hàng đang được giao
        return const Color(0xff2196F3);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: "Đơn Nhập Vật Tư", isBackNavigation: true),
      backgroundColor: const Color(0xfff7f8fa),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final retailOrderBloc = BlocProvider.of<RetailOrderBloc>(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BlocProvider.value(
                value: retailOrderBloc,
                child: const CreateRetailOrderScreen(),
              ),
            ),
          ).then((value) {
            if (value == true) {
              _onRefresh();
            }
          });
        },
        backgroundColor: ColorUtil.bangladeshGreen,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Tạo đơn mới",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: BlocBuilder<RetailOrderBloc, RetailOrderState>(
              buildWhen: (previous, current) =>
                  current is RetailOrderLoading ||
                  current is RetailOrderLoadFailure ||
                  current is RetailOrderLoadSuccess,
              builder: (context, state) {
                if (state is RetailOrderLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: ColorUtil.bangladeshGreen,
                    ),
                  );
                } else if (state is RetailOrderLoadFailure) {
                  return _buildErrorView(state.error);
                } else if (state is RetailOrderLoadSuccess) {
                  final orders = state.orders;
                  if (orders.isEmpty) {
                    return _buildEmptyView();
                  }
                  return RefreshIndicator(
                    onRefresh: () async => _onRefresh(),
                    color: ColorUtil.bangladeshGreen,
                    child: ListView.builder(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 24),
                      itemCount: orders.length + (state.isFetchingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == orders.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: ColorUtil.bangladeshGreen,
                                strokeWidth: 2.5,
                              ),
                            ),
                          );
                        }
                        return _buildOrderCard(orders[index]);
                      },
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: paddingHorizontal,
        vertical: 12,
      ),
      color: Colors.white,
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: "Tìm kiếm theo mã, tên, SĐT...",
          hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
          prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 22),
          suffixIcon: _searchController.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = "";
                    });
                    _bloc.add(
                      const FetchRetailOrdersEvent(isRefresh: true, search: ""),
                    );
                  },
                  child: const Icon(Icons.clear, color: Colors.grey, size: 20),
                )
              : null,
          filled: true,
          fillColor: const Color(0xfff1f2f6),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 0,
            horizontal: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.6,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              "Không tìm thấy đơn hàng nào",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _onRefresh,
              child: const Text(
                "Tải lại danh sách",
                style: TextStyle(
                  color: ColorUtil.bangladeshGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 56, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(
              "Lấy danh sách thất bại!",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _onRefresh,
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorUtil.bangladeshGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Thử lại",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(RetailOrder order) {
    final statusColor = _getStatusColor(order.status);
    final orderCode = (order.code != null && order.code!.isNotEmpty)
        ? order.code!
        : 'SB_${order.id}';

    double productTotal = 0;
    if (order.orderdetails != null) {
      for (var detail in order.orderdetails!) {
        productTotal += double.tryParse(detail.amount ?? '0') ?? 0;
      }
    }
    double shipFee =
        double.tryParse(order.retailOrderShipment?.baseShippingFee ?? '0') ?? 0;
    double grandTotal = productTotal + shipFee;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: paddingHorizontal,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        orderCode,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: ColorUtil.raisinBlack,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDatetime(
                          order.orderDate ?? order.createdAt?.toString(),
                        ),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order.statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xfff1f2f6)),

          // Customer Info
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                  Icons.person_outline,
                  "Người nhận",
                  order.orderUserName ?? 'Chưa cập nhật',
                ),
                const SizedBox(height: 8),
                _buildPhoneRow(order.orderUserPhone),
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.location_on_outlined,
                  "Địa chỉ",
                  order.orderUserAddress ?? 'Chưa cập nhật',
                ),
                if (order.orderUserNote != null &&
                    order.orderUserNote!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.note_alt_outlined,
                    "Ghi chú",
                    order.orderUserNote!,
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xfff1f2f6)),

          // Product list
          if (order.orderdetails != null && order.orderdetails!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Sản phẩm",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: ColorUtil.raisinBlack,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...order.orderdetails!.map(
                    (detail) => _buildProductItem(detail),
                  ),
                ],
              ),
            ),
          const Divider(height: 1, color: Color(0xfff1f2f6)),

          // Footer / Total
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Tạm tính",
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    Text(
                      _formatCurrency(productTotal),
                      style: const TextStyle(
                        fontSize: 13,
                        color: ColorUtil.raisinBlack,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Phí vận chuyển",
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    Text(
                      _formatCurrency(shipFee),
                      style: const TextStyle(
                        fontSize: 13,
                        color: ColorUtil.raisinBlack,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Tổng thanh toán",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: ColorUtil.raisinBlack,
                      ),
                    ),
                    Text(
                      _formatCurrency(grandTotal),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: ColorUtil.bangladeshGreen,
                      ),
                    ),
                  ],
                ),
                if (order.status == '4') ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: Color(0xfff1f2f6)),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showReceiveOrderDialog(order),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorUtil.bangladeshGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(
                        Icons.check_circle_outline,
                        color: Colors.white,
                      ),
                      label: const Text(
                        "Đã Nhận Hàng",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey[500]),
        const SizedBox(width: 8),
        Text(
          "$label: ",
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, color: ColorUtil.raisinBlack),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneRow(String? phone) {
    final displayPhone = (phone != null && phone.isNotEmpty)
        ? phone
        : 'Chưa cập nhật';
    final hasPhone = phone != null && phone.isNotEmpty;

    return Row(
      children: [
        Icon(Icons.phone_outlined, size: 18, color: Colors.grey[500]),
        const SizedBox(width: 8),
        Text(
          "Điện thoại: ",
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
        Expanded(
          child: hasPhone
              ? InkWell(
                  onTap: () async {
                    final telUri = Uri.parse('tel:$phone');
                    if (await canLaunchUrl(telUri)) {
                      await launchUrl(telUri);
                    }
                  },
                  child: Text(
                    displayPhone,
                    style: const TextStyle(
                      fontSize: 13,
                      color: ColorUtil.bangladeshGreen,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                )
              : Text(
                  displayPhone,
                  style: const TextStyle(
                    fontSize: 13,
                    color: ColorUtil.raisinBlack,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildProductItem(RetailOrderDetails detail) {
    final product = detail.product;
    final name = product?.name ?? 'Sản phẩm không tên';
    final quantity = detail.quantity ?? '0';
    final price = detail.unitPrice ?? '0';

    String imageUrl = '';
    if (product?.images != null && product!.images!.isNotEmpty) {
      final link = product.images![0].link;
      if (link != null && link.isNotEmpty) {
        imageUrl = "$protocol${AppConfig.instance.values.apiUrl}$link";
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 50,
              height: 50,
              color: const Color(0xfff1f2f6),
              child: imageUrl.isNotEmpty
                  ? ImageUtil.loadNetWorkImage(
                      url: imageUrl,
                      height: 50,
                      width: 50,
                    )
                  : const Icon(Icons.image, color: Colors.grey, size: 24),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: ColorUtil.raisinBlack,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "SL: $quantity",
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Text(
                      _formatCurrency(price),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: ColorUtil.raisinBlack,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showReceiveOrderDialog(RetailOrder order) async {
    final shipment = order.retailOrderShipment;
    if (shipment == null ||
        shipment.shipmentUsers == null ||
        shipment.shipmentUsers!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không tìm thấy thông tin phân công giao hàng!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final currentUserId = App.instance.userApp?.id?.toString();
    RetailOrderShipmentAssign? myAssignment;
    for (var assign in shipment.shipmentUsers!) {
      if (assign.userId == currentUserId) {
        myAssignment = assign;
        break;
      }
    }
    myAssignment ??= shipment.shipmentUsers!.first;

    final assignmentId = myAssignment.id.toString();

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          ReceiveOrderDialog(orderCode: order.code ?? 'SB_${order.id}'),
    );

    if (result != null) {
      final String note = result['note'];
      final List<File> images = result['images'];

      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: ColorUtil.bangladeshGreen),
        ),
      );

      try {
        String successMessage = 'Cập nhật trạng thái đã nhận hàng thành công!';
        // Upload images one by one sequentially
        for (int i = 0; i < images.length; i++) {
          final response = await _bloc.apiRepository.storeAssignmentImage(
            id: assignmentId,
            note: note,
            image: images[i],
          );
          print(response.message);

          if (response.status != 200 &&
              response.status != 1 &&
              !(response.message == null && response.data != null)) {
            throw Exception(
              response.message ?? 'Cập nhật ảnh thứ ${i + 1} thất bại!',
            );
          }

          if (response.message != null && response.message!.isNotEmpty) {
            successMessage = response.message!;
          }
        }

        if (mounted) Navigator.pop(context); // Close loading spinner

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(successMessage),
              backgroundColor: ColorUtil.bangladeshGreen,
            ),
          );
          _onRefresh();
        }
      } catch (e) {
        if (mounted) Navigator.pop(context); // Close loading spinner
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi: ${e.toString()}'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    }
  }
}

class ReceiveOrderDialog extends StatefulWidget {
  final String orderCode;

  const ReceiveOrderDialog({super.key, required this.orderCode});

  @override
  State<ReceiveOrderDialog> createState() => _ReceiveOrderDialogState();
}

class _ReceiveOrderDialogState extends State<ReceiveOrderDialog> {
  final TextEditingController _noteController = TextEditingController();
  final List<File> _images = [];
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  Future<File> _resizeImage(File imageFile) async {
    Uint8List imageBytes = await imageFile.readAsBytes();
    img.Image? originalImage = img.decodeImage(imageBytes);

    if (originalImage == null) throw Exception('Không thể đọc ảnh');

    const maxWidth = 800.0;
    const maxHeight = 800.0;
    double ratio = originalImage.width / originalImage.height;

    int newWidth = originalImage.width;
    int newHeight = originalImage.height;

    if (originalImage.width > maxWidth || originalImage.height > maxHeight) {
      if (ratio > 1) {
        newWidth = maxWidth.toInt();
        newHeight = maxWidth ~/ ratio;
      } else {
        newHeight = maxHeight.toInt();
        newWidth = (maxHeight * ratio).toInt();
      }
    }

    img.Image resizedImage = img.copyResize(
      originalImage,
      width: newWidth,
      height: newHeight,
      interpolation: img.Interpolation.linear,
    );

    final directory = await getTemporaryDirectory();
    final resizedFile = File(
      '${directory.path}/resized_${DateTime.now().millisecondsSinceEpoch}_${_images.length}.jpg',
    );
    await resizedFile.writeAsBytes(img.encodeJpg(resizedImage, quality: 85));

    return resizedFile;
  }

  Future<void> _showImageSourceOptions() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(
                  Icons.photo_camera,
                  color: ColorUtil.bangladeshGreen,
                ),
                title: const Text('Chụp ảnh mới (Camera)'),
                onTap: () {
                  Navigator.of(context).pop();
                  _getImageFromCamera();
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: ColorUtil.bangladeshGreen,
                ),
                title: const Text('Chọn từ thư viện (Gallery)'),
                onTap: () {
                  Navigator.of(context).pop();
                  _getImagesFromGallery();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _getImageFromCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      _processImages([image]);
    }
  }

  Future<void> _getImagesFromGallery() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      _processImages(images);
    }
  }

  Future<void> _processImages(List<XFile> images) async {
    setState(() {
      _isLoading = true;
    });
    try {
      for (var image in images) {
        final File resizedImage = await _resizeImage(File(image.path));
        setState(() {
          _images.add(resizedImage);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi xử lý ảnh: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Xác Nhận Nhận Hàng',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: ColorUtil.raisinBlack,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Đơn hàng: ${widget.orderCode}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _noteController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Ghi chú nhận hàng',
                    hintText:
                        'Nhập ghi chú (ví dụ: người nhận, tình trạng vật tư...)',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập ghi chú';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Hình ảnh thực tế (Yêu cầu ít nhất 1 ảnh)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: ColorUtil.raisinBlack,
                  ),
                ),
                const SizedBox(height: 8),
                _images.isEmpty
                    ? InkWell(
                        onTap: _isLoading ? null : _showImageSourceOptions,
                        child: Container(
                          height: 120,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                            color: const Color(0xfff7f8fa),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_a_photo_outlined,
                                size: 36,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Bấm để chọn/chụp ảnh',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                        itemCount: _images.length + 1,
                        itemBuilder: (context, index) {
                          if (index == _images.length) {
                            return InkWell(
                              onTap: _isLoading
                                  ? null
                                  : _showImageSourceOptions,
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(8),
                                  color: const Color(0xfff7f8fa),
                                ),
                                child: Icon(
                                  Icons.add_a_photo_outlined,
                                  color: Colors.grey[600],
                                ),
                              ),
                            );
                          }
                          return Stack(
                            children: [
                              Positioned.fill(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    _images[index],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () => _removeImage(index),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(4),
                                    child: const Icon(
                                      Icons.close,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        'Hủy',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                if (_images.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Vui lòng chọn ít nhất 1 hình ảnh!',
                                      ),
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  );
                                  return;
                                }
                                Navigator.pop(context, {
                                  'note': _noteController.text.trim(),
                                  'images': _images,
                                });
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorUtil.bangladeshGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Nhận Hàng',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }
}
