import 'dart:io';
import 'dart:ui' as ui;
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_format_money_vietnam/flutter_format_money_vietnam.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:socbay/application.dart';
import 'package:socbay/blocs/staff/order/order_manager_bloc.dart';
import 'package:socbay/blocs/staff/order/order_manager_event.dart';
import 'package:socbay/blocs/staff/order/order_manager_state.dart';
import 'package:socbay/constants/constants.dart';
import 'package:socbay/data/model/order_detail_model.dart';
import 'package:socbay/data/model/staff_sales_income_model.dart';
import 'package:socbay/routes.dart';
import 'package:socbay/utils/color_util.dart';
import 'package:socbay/widgets/button_widget.dart';
import 'package:socbay/widgets/date_range_form_field.dart';
import 'package:socbay/widgets/loading_indicator.dart';
import 'package:socbay/widgets/my_app_bar.dart';

class OrderManagerScreen extends StatefulWidget {
  const OrderManagerScreen({super.key});

  @override
  State<OrderManagerScreen> createState() => _OrderManagerScreenState();
}

class _OrderManagerScreenState extends State<OrderManagerScreen> {
  late OrderManagerBloc _bloc;
  DateTimeRange? myDateRange;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _reportKey = GlobalKey();
  bool _isStatsExpanded = false;

  @override
  void initState() {
    _bloc = BlocProvider.of(context);
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime.now();
    myDateRange = DateTimeRange(start: start, end: end);

    var startInitTime = start.toString();
    var endInitTime = end.add(const Duration(seconds: (23 * 60 + 59) * 60));
    _bloc.add(
      OrderManagerListEvent(
        isRefresh: true,
        start: startInitTime.toString(),
        end: endInitTime.toString(),
        page: 1,
      ),
    );
    _scrollController.addListener(_onScroll);
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      var end = myDateRange?.end ?? DateTime.now();
      var start =
          myDateRange?.start ??
          DateTime(DateTime.now().year, DateTime.now().month, 1);
      if (!_bloc.isLoading &&
          !_bloc.isLoadMoreLoading &&
          _bloc.currentPage < _bloc.lastPage) {
        _bloc.add(
          OrderManagerListEvent(
            start: start.toString(),
            end: end
                .add(const Duration(seconds: (23 * 60 + 59) * 60))
                .toString(),
            page: _bloc.currentPage + 1,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OrderManagerBloc, OrderManagerState>(
      builder: _builder,
      listener: _listener,
    );
  }

  void _listener(BuildContext context, OrderManagerState state) {}

  Widget _builder(BuildContext context, OrderManagerState state) {
    return PopScope(
      canPop: true,
      child: Scaffold(
        appBar: MyAppBar(
          title: "Quản lý đơn hàng",
          isBackNavigation: true,
          onBack: () async {
            Navigator.pop(context);
          },
        ),
        body: Stack(
          children: [
            RefreshIndicator(
              onRefresh: () async {
                final now = DateTime.now();
                var start = DateTime(now.year, now.month, 1);
                var end = DateTime.now();
                setState(() {
                  myDateRange = DateTimeRange(start: start, end: end);
                });
                _bloc.add(
                  OrderManagerListEvent(
                    isRefresh: true,
                    start: start.toString(),
                    end: end
                        .add(const Duration(seconds: (23 * 60 + 59) * 60))
                        .toString(),
                    page: 1,
                  ),
                );
              },
              child: LoadingIndicator(
                isLoading: _bloc.isLoading,
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: paddingHorizontal,
                    vertical: paddingVertical,
                  ),
                  itemCount:
                      1 +
                      _bloc.staffLstOrders.length +
                      (_bloc.isLoadMoreLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _buildHeader();
                    }

                    if (index == _bloc.staffLstOrders.length + 1) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: ColorUtil.bangladeshGreen,
                          ),
                        ),
                      );
                    }

                    final orderIndex = index - 1;
                    return _buildOrderCard(
                      context,
                      _bloc.staffLstOrders[orderIndex],
                    );
                  },
                ),
              ),
            ),
            Positioned(
              left: -9999,
              top: -9999,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: RepaintBoundary(
                  key: _reportKey,
                  child: SizedBox(
                    width: 850,
                    child: Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(24),
                      child: _buildReportContent(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _datetimeRange() {
    return DateRangeField(
      dateFormat: DateFormat("dd/MM/yyyy"),
      firstDate: DateTime(1990),
      enabled: true,
      initialValue: DateTimeRange(
        start: myDateRange != null
            ? myDateRange!.start
            : DateTime(DateTime.now().year, DateTime.now().month, 1),
        end: myDateRange != null ? myDateRange!.end : DateTime.now(),
      ),
      decoration: const InputDecoration(
        labelText: 'Thời gian',
        prefixIcon: Icon(Icons.date_range, color: ColorUtil.bangladeshGreen),
        hintText: 'Please select a start and end date',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value!.start.isBefore(DateTime.now())) {
          return 'Please enter a later start date';
        }
        return null;
      },
      onSaved: (value) {
        setState(() {
          myDateRange = value!;
        });
      },
      onChanged: (value) {
        setState(() {
          myDateRange = value;
          var end = myDateRange?.end;
          _bloc.add(
            OrderManagerListEvent(
              isRefresh: true,
              start: myDateRange?.start.toString() ?? '',
              end:
                  end
                      ?.add(const Duration(seconds: (23 * 60 + 59) * 60))
                      .toString() ??
                  '',
              page: 1,
            ),
          );
        });
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.15), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: ColorUtil.graniteGray,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: ColorUtil.raisinBlack,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Tổng đơn',
            value: _bloc.totalOrderAll.toString(),
            icon: Icons.assignment_outlined,
            color: ColorUtil.primary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            title: 'Tổng doanh thu',
            value: (_bloc.totalPriceAll).toInt().toVND(),
            icon: Icons.account_balance_wallet_outlined,
            color: ColorUtil.green,
          ),
        ),
      ],
    );
  }

  int _getSumInt(String? Function(StaffSalesIncomeModel) getter) {
    int sum = 0;
    for (var item in _bloc.staffSalesIncomes) {
      final val = getter(item);
      if (val != null) {
        sum += int.tryParse(val) ?? 0;
      }
    }
    return sum;
  }

  double _getSumDouble(String? Function(StaffSalesIncomeModel) getter) {
    double sum = 0;
    for (var item in _bloc.staffSalesIncomes) {
      final val = getter(item);
      if (val != null) {
        sum += double.tryParse(val) ?? 0.0;
      }
    }
    return sum;
  }

  Widget _buildDetailedStats() {
    if (_bloc.staffSalesIncomes.isEmpty) {
      return const SizedBox.shrink();
    }

    final lapMayCount = _getSumInt((item) => item.totalOrderLapMay);
    final lapMayRev = _getSumDouble((item) => item.totalPriceLapMay);

    final thayTheCount = _getSumInt((item) => item.totalOrderThayThe);
    final thayTheRev = _getSumDouble((item) => item.totalPriceThayThe);

    final vsbdCount = _getSumInt((item) => item.totalOrderVsbd);
    final vsbdRev = _getSumDouble((item) => item.totalPriceVsbd);

    final onlineCount = _getSumInt((item) => item.totalOrderOnline);
    final onlineRev = _getSumDouble((item) => item.totalPriceOnline);

    final shipCount = _getSumInt((item) => item.totalOrderShip);
    final shipRev = _getSumDouble((item) => item.totalPriceShip);

    final locTongChinhCount = _getSumInt((item) => item.totalOrderLocTongChinh);
    final locTongChinhRev = _getSumDouble(
      (item) => item.totalPriceLocTongChinh,
    );

    final locTongPhuCount = _getSumInt((item) => item.totalOrderLocTongPhu);
    final locTongPhuRev = _getSumDouble((item) => item.totalPriceLocTongPhu);

    final rentCount = _getSumInt((item) => item.totalRentOrder);
    final rentRev = _getSumDouble((item) => item.totalPriceRent);

    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: ColorUtil.primary.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ColorUtil.primary.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isStatsExpanded = !_isStatsExpanded;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  const Icon(
                    Icons.analytics_outlined,
                    color: ColorUtil.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Thống kê chi tiết loại đơn',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: ColorUtil.primary,
                      ),
                    ),
                  ),
                  Icon(
                    _isStatsExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: ColorUtil.graniteGray,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
          if (_isStatsExpanded) ...[
            const Divider(height: 1, thickness: 0.5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                children: [
                  _buildDetailRow('Đơn lắp máy', lapMayCount, lapMayRev),
                  _buildDetailRow('Đơn thay thế', thayTheCount, thayTheRev),
                  _buildDetailRow('Đơn vsbd', vsbdCount, vsbdRev),
                  _buildDetailRow('Đơn online', onlineCount, onlineRev),
                  _buildDetailRow('Đơn ship', shipCount, shipRev),
                  _buildDetailRow(
                    'Đơn lọc tổng chính',
                    locTongChinhCount,
                    locTongChinhRev,
                  ),
                  _buildDetailRow(
                    'Đơn lọc tổng phụ',
                    locTongPhuCount,
                    locTongPhuRev,
                  ),
                  _buildDetailRow('Đơn thuê máy', rentCount, rentRev),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, int count, double revenue) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: ColorUtil.raisinBlack,
            ),
          ),
          Text(
            '$count đơn • ${revenue.toInt().toVND()}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: ColorUtil.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _datetimeRange(),
        const SizedBox(height: 10),
        _buildStatsGrid(),
        _buildDetailedStats(),
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0, top: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Danh sách đơn hàng',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: ColorUtil.raisinBlack,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _exportReportImage,
                icon: const Icon(
                  Icons.share_outlined,
                  size: 16,
                  color: Colors.white,
                ),
                label: const Text(
                  'Xuất báo cáo',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorUtil.bangladeshGreen,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _exportReportImage() async {
    if (_bloc.staffLstOrders.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không có đơn hàng nào để xuất báo cáo!')),
      );
      return;
    }

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: ColorUtil.bangladeshGreen),
        ),
      );

      // Force state update to ensure 850px report layout is fresh
      setState(() {});
      await Future.delayed(const Duration(milliseconds: 150));

      final boundary =
          _reportKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;

      if (boundary == null) {
        if (mounted && Navigator.canPop(context)) {
          Navigator.pop(context);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Không thể tạo khung hình báo cáo, vui lòng thử lại!',
            ),
          ),
        );
        return;
      }

      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      if (byteData == null) return;
      final pngBytes = byteData.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final ktvName = (App.instance.userApp?.username ?? 'ktv').replaceAll(
        ' ',
        '_',
      );
      final fileName =
          'phieu_cong_viec_${ktvName}_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(pngBytes);

      final startDate =
          myDateRange?.start ??
          DateTime(DateTime.now().year, DateTime.now().month, 1);
      final endDate = myDateRange?.end ?? DateTime.now();
      final startStr = DateFormat('dd/MM/yyyy').format(startDate);
      final endStr = DateFormat('dd/MM/yyyy').format(endDate);
      final dateRangeText = (startStr == endStr)
          ? startStr
          : '$startStr - $endStr';

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text:
              'Báo cáo công việc - KTV ${App.instance.userApp?.username ?? ''} ($dateRangeText)',
        ),
      );
    } catch (e) {
      print("Error exporting report image: $e");
      if (mounted) {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Có lỗi khi xuất báo cáo: $e')));
      }
    }
  }

  Widget _buildReportContent() {
    final ktvName = App.instance.userApp?.username ?? '';

    final startDate =
        myDateRange?.start ??
        DateTime(DateTime.now().year, DateTime.now().month, 1);
    final endDate = myDateRange?.end ?? DateTime.now();

    final startStr = DateFormat('dd/MM/yyyy').format(startDate);
    final endStr = DateFormat('dd/MM/yyyy').format(endDate);
    final dateRangeText = (startStr == endStr)
        ? startStr
        : '$startStr - $endStr';

    final shortStart = DateFormat('dd/MM').format(startDate);
    final shortEnd = DateFormat('dd/MM').format(endDate);
    final shortDateText = (shortStart == shortEnd)
        ? shortStart
        : '$shortStart-$shortEnd';

    double grandCash = 0;
    double grandTransfer = 0;
    double totalThayLoiRev = _getSumDouble((item) => item.totalPriceThayThe);

    List<Map<String, dynamic>> orderRows = [];
    for (var order in _bloc.staffLstOrders) {
      double price = double.tryParse(order.price ?? '0') ?? 0;
      if (order.type == '4') {
        price = 80000;
      } else if (order.subType == '8') {
        price = 200000;
      }

      double cash = 0;
      double transfer = 0;

      if (order.orderPayment != null && order.orderPayment!.isNotEmpty) {
        for (var p in order.orderPayment!) {
          double amt = double.tryParse(p.amount ?? '0') ?? 0;
          if (p.method == '0') {
            cash += amt;
          } else if (p.method == '1') {
            transfer += amt;
          }
        }
      }

      grandCash += cash;
      grandTransfer += transfer;

      String subType = _getSubTypeText(order);

      final saleName =
          order.sale?.username ??
          order.sale?.phone ??
          order.user?.username ??
          '';

      orderRows.add({
        'orderId': order.id?.toString() ?? '',
        'saleName': saleName,
        'subType': subType,
        'price': price,
        'cash': cash,
        'transfer': transfer,
        'products': _getProductsText(order),
        'note': order.ghichu ?? '',
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Center(
          child: Text(
            'PHIẾU CÔNG VIỆC HÀNG NGÀY',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 13, color: Colors.black),
                children: [
                  const TextSpan(
                    text: 'Họ tên kỹ thuật: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: ktvName,
                    style: const TextStyle(
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
            RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 13, color: Colors.black),
                children: [
                  const TextSpan(
                    text: 'Ngày: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: dateRangeText,
                    style: const TextStyle(
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        const Text(
          'BÁO CÁO KỸ THUẬT VIÊN',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Table(
          border: TableBorder.all(color: Colors.black, width: 1.0),
          columnWidths: const {
            0: FlexColumnWidth(1.2),
            1: FlexColumnWidth(1.8),
            2: FlexColumnWidth(1.8),
            3: FlexColumnWidth(1.8),
            4: FlexColumnWidth(1.8),
            5: FlexColumnWidth(1.8),
            6: FlexColumnWidth(3.8),
            7: FlexColumnWidth(2.4),
          },
          children: [
            TableRow(
              decoration: const BoxDecoration(color: Color(0xFFF0F0F0)),
              children: [
                _buildTableCell('Đơn Số', isHeader: true),
                _buildTableCell('Tên Sale', isHeader: true),
                _buildTableCell('Loại đơn', isHeader: true),
                _buildTableCell('Tổng số tiền', isHeader: true),
                _buildTableCell('TT Tiền mặt', isHeader: true),
                _buildTableCell('TT Chuyển khoản', isHeader: true),
                _buildTableCell('Sản phẩm', isHeader: true),
                _buildTableCell('Ghi chú', isHeader: true),
              ],
            ),
            ...orderRows.map((row) {
              return TableRow(
                children: [
                  _buildTableCell(
                    row['orderId'],
                    isBold: true,
                    align: TextAlign.center,
                  ),
                  _buildTableCell(row['saleName']),
                  _buildTableCell(row['subType']),
                  _buildTableCell(
                    _formatK(row['price']),
                    align: TextAlign.right,
                  ),
                  _buildTableCell(
                    _formatK(row['cash'], isZeroBlank: true),
                    align: TextAlign.right,
                  ),
                  _buildTableCell(
                    _formatK(row['transfer'], isZeroBlank: true),
                    align: TextAlign.right,
                  ),
                  _buildTableCell(row['products']),
                  _buildTableCell(row['note']),
                ],
              );
            }),
            TableRow(
              children: [
                TableCell(
                  child: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 6,
                    ),
                    child: const Text(
                      'TỔNG',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11.5,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                const TableCell(child: SizedBox.shrink()),
                const TableCell(child: SizedBox.shrink()),
                _buildTableCell(
                  _formatK(_bloc.totalPriceAll),
                  isBold: true,
                  align: TextAlign.right,
                ),
                _buildTableCell(
                  _formatK(grandCash),
                  isBold: true,
                  align: TextAlign.right,
                ),
                _buildTableCell(
                  _formatK(grandTransfer),
                  isBold: true,
                  align: TextAlign.right,
                ),
                const TableCell(child: SizedBox.shrink()),
                const TableCell(child: SizedBox.shrink()),
              ],
            ),
            TableRow(
              children: [
                const TableCell(child: SizedBox.shrink()),
                TableCell(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 6,
                    ),
                    child: const Text(
                      'TIỀN MẶT PHẢI NỘP',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11.5,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                // const TableCell(child: SizedBox.shrink()),
                const TableCell(child: SizedBox.shrink()),
                _buildTableCell(
                  _formatK(grandCash),
                  isBold: true,
                  align: TextAlign.left,
                ),
                const TableCell(child: SizedBox.shrink()),
                const TableCell(child: SizedBox.shrink()),
                const TableCell(child: SizedBox.shrink()),
                const TableCell(child: SizedBox.shrink()),
              ],
            ),
            TableRow(
              children: [
                const TableCell(child: SizedBox.shrink()),
                TableCell(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 6,
                    ),
                    child: const Text(
                      'Doanh Thu Thay Lõi',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11.5,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                // const TableCell(child: SizedBox.shrink()),
                const TableCell(child: SizedBox.shrink()),
                _buildTableCell(
                  _formatK(totalThayLoiRev),
                  isBold: true,
                  align: TextAlign.left,
                ),
                const TableCell(child: SizedBox.shrink()),
                const TableCell(child: SizedBox.shrink()),
                _buildTableCell(
                  'Thưởng nóng:',
                  isBold: true,
                  align: TextAlign.left,
                ),
                const TableCell(child: SizedBox.shrink()),
              ],
            ),
          ],
        ),
        const SizedBox(height: 14),
        const Text(
          '551999 - CTCP CN VA DV SHOME - VPBank',
          style: TextStyle(
            fontSize: 12.0,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Nội dung CK: $ktvName ($shortDateText)',
          style: const TextStyle(fontSize: 11.0, color: Colors.black),
        ),
      ],
    );
  }

  Widget _buildTableCell(
    String text, {
    bool isHeader = false,
    bool isBold = false,
    TextAlign align = TextAlign.left,
  }) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: Text(
          text,
          textAlign: align,
          style: TextStyle(
            fontSize: isHeader ? 11.5 : 11.0,
            fontWeight: (isHeader || isBold)
                ? FontWeight.bold
                : FontWeight.normal,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  String _formatK(double val, {bool isZeroBlank = false}) {
    if (val == 0) {
      return isZeroBlank ? '' : '0';
    }
    double inK = val / 1000;
    final numFormat = NumberFormat('#,###', 'vi_VN');
    return '${numFormat.format(inK.round())}k';
  }

  String _getSubTypeText(OrderDetailModel order) {
    final type = order.type;
    String baseType = 'Đơn bán máy';
    if (type == '2') {
      baseType = 'Dịch vụ';
    } else if (type == '4') {
      baseType = 'Thuê';
    }

    final subTypeRaw = order.subType?.trim();
    if (subTypeRaw == null || subTypeRaw.isEmpty) {
      return baseType;
    }

    String subTypeLabel;
    switch (subTypeRaw) {
      case '1':
        subTypeLabel = 'Lắp máy';
        break;
      case '2':
        subTypeLabel = 'Thay thế';
        break;
      case '3':
        subTypeLabel = 'VSBD';
        break;
      case '4':
        subTypeLabel = 'Online';
        break;
      case '5':
        subTypeLabel = 'Ship';
        break;
      case '6':
        subTypeLabel = 'Lọc tổng chính';
        break;
      case '7':
        subTypeLabel = 'Lọc tổng phụ';
        break;
      case '8':
        subTypeLabel = 'Lắp máy sàn';
        break;
      default:
        subTypeLabel = subTypeRaw;
        break;
    }

    return '$baseType ($subTypeLabel)';
  }

  String _getProductsText(OrderDetailModel order) {
    if (order.orderFilterCoresModel != null &&
        order.orderFilterCoresModel!.isNotEmpty) {
      final validProductNames = <String>[];
      for (var c in order.orderFilterCoresModel!) {
        if (c.replaceDatePromise != null && c.replaceDatePromise!.isNotEmpty) {
          continue;
        }

        final name = c.name?.trim() ?? '';
        if (name.isEmpty) continue;

        if (name.contains('Lắp đặt mới; VSBD; Dv khác') ||
            name.contains('Lắp đặt mới; VSBD') ||
            name.contains('Thu tiền đơn thuê')) {
          continue;
        }

        if (!validProductNames.contains(name)) {
          validProductNames.add(name);
        }
      }

      if (validProductNames.isNotEmpty) {
        return validProductNames.join(', ');
      }
    }
    return '';
  }

  Widget _buildStatusBadge(String? type) {
    String text = 'Đơn dịch vụ';
    Color bgColor = const Color(0xFFF0FDFA);
    Color textColor = const Color(0xFF0F766E);

    if (type == '3' || type == '4') {
      text = 'Đơn thuê';
      bgColor = const Color(0xFFEFF6FF);
      textColor = const Color(0xFF1D4ED8);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: textColor.withValues(alpha: 0.15), width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _computePaymentStatus(OrderDetailModel order) {
    if (order.orderPayment != null && order.orderPayment!.isNotEmpty) {
      bool hasUnpaid = order.orderPayment!.any((p) => p.paymentStatus == '0');
      if (hasUnpaid) {
        return '0';
      }
      bool allPaid = order.orderPayment!.every((p) => p.paymentStatus == '1');
      if (allPaid) {
        return '1';
      }
    }
    return order.paymentStatus ?? '0';
  }

  Widget _buildPaymentStatusBadge(String? status) {
    String text = 'Chưa thanh toán';
    Color bgColor = const Color(0xFFFEF2F2);
    Color textColor = const Color(0xFFDC2626);

    if (status == '1') {
      text = 'Đã thanh toán';
      bgColor = const Color(0xFFF0FDF4);
      textColor = const Color(0xFF16A34A);
    } else if (status == '2') {
      text = 'Chờ xác nhận';
      bgColor = const Color(0xFFFEF3C7);
      textColor = const Color(0xFFD97706);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: textColor.withValues(alpha: 0.15), width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, OrderDetailModel order) {
    var finalPrice = Decimal.parse(order.price ?? "0");
    String formattedPrice = finalPrice.toBigInt().toVND();

    double rating = order.rate != null
        ? double.tryParse(order.rate!) ?? 0.0
        : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.1), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Đơn hàng #MB_${order.id}",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: ColorUtil.raisinBlack,
                  ),
                ),
                _buildStatusBadge(order.type),
              ],
            ),
            const SizedBox(height: 12),
            if (order.tvInsteadDate != null &&
                order.tvInsteadDate!.isNotEmpty) ...[
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: ColorUtil.spanishGray,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Ngày thay: ",
                    style: TextStyle(
                      fontSize: 13,
                      color: ColorUtil.graniteGray,
                    ),
                  ),
                  Text(
                    order.tvInsteadDate!.substring(0, 10),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: ColorUtil.raisinBlack,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
            ],
            if (order.tvNextInsteadDate != null &&
                order.tvNextInsteadDate!.isNotEmpty) ...[
              Row(
                children: [
                  const Icon(
                    Icons.event,
                    size: 14,
                    color: ColorUtil.spanishGray,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Ngày thay tiếp: ",
                    style: TextStyle(
                      fontSize: 13,
                      color: ColorUtil.graniteGray,
                    ),
                  ),
                  Text(
                    order.tvNextInsteadDate!.substring(0, 10),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: ColorUtil.raisinBlack,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
            ],
            if (order.orderPayment != null &&
                order.orderPayment!.isNotEmpty) ...[
              Row(
                children: [
                  const Icon(
                    Icons.payment_outlined,
                    size: 14,
                    color: ColorUtil.spanishGray,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Thanh toán: ",
                    style: TextStyle(
                      fontSize: 13,
                      color: ColorUtil.graniteGray,
                    ),
                  ),
                  _buildPaymentStatusBadge(_computePaymentStatus(order)),
                ],
              ),
              const SizedBox(height: 6),
            ],
            if (rating > 0) ...[
              Row(
                children: [
                  const Icon(Icons.star, size: 14, color: Colors.amber),
                  const SizedBox(width: 8),
                  const Text(
                    "Đánh giá: ",
                    style: TextStyle(
                      fontSize: 13,
                      color: ColorUtil.graniteGray,
                    ),
                  ),
                  RatingBarIndicator(
                    rating: rating,
                    direction: Axis.horizontal,
                    unratedColor: Colors.amber.withAlpha(60),
                    itemCount: 5,
                    itemSize: 13.0,
                    itemPadding: const EdgeInsets.symmetric(horizontal: 1.0),
                    itemBuilder: (context, _) =>
                        const Icon(Icons.star, color: Colors.amber),
                  ),
                ],
              ),
              const SizedBox(height: 6),
            ],
            const Divider(height: 24, thickness: 0.5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Tổng tiền",
                      style: TextStyle(
                        fontSize: 11,
                        color: ColorUtil.spanishGray,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formattedPrice,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: ColorUtil.green,
                      ),
                    ),
                  ],
                ),
                ButtonWidget(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      Routes.coreReplacementServiceScreen,
                      arguments: {
                        "orderDetail": OrderDetailModel(id: order.id),
                      },
                    );
                  },
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  borderRadius: BorderRadius.circular(20.0),
                  color: ColorUtil.brightYellow,
                  child: const Row(
                    children: [
                      Text(
                        "Chi tiết",
                        style: TextStyle(
                          color: ColorUtil.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 10,
                        color: ColorUtil.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
