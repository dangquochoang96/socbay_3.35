import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:socbay/blocs/retail_order/retail_order_bloc.dart';
import 'package:socbay/blocs/retail_order/retail_order_event.dart';
import 'package:socbay/blocs/retail_order/retail_order_state.dart';
import 'package:socbay/config/app_config.dart';
import 'package:socbay/constants/constants.dart';
import 'package:socbay/data/model/retail_order_model.dart';
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
      appBar: MyAppBar(title: "Đơn Hàng Bán Lẻ", isBackNavigation: true),
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
        : 'BB_${order.id}';

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
}
