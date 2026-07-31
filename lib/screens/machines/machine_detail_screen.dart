import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_format_money_vietnam/flutter_format_money_vietnam.dart';
import 'package:intl/intl.dart';
import 'package:socbay/blocs/machine/machine_detail/machine_detail_bloc.dart';
import 'package:socbay/blocs/machine/machine_detail/machine_detail_event.dart';
import 'package:socbay/blocs/machine/machine_detail/machine_detail_state.dart';
import 'package:socbay/config/app_config.dart';
import 'package:socbay/data/model/order_model.dart';
import 'package:socbay/data/model/order_rent_model.dart';
import 'package:socbay/routes.dart';
import 'package:socbay/utils/color_util.dart';
import 'package:socbay/utils/image_util.dart';
import 'package:socbay/widgets/loading_indicator.dart';
import 'package:socbay/widgets/my_app_bar.dart';

class MachineDetailScreen extends StatefulWidget {
  const MachineDetailScreen({super.key});

  @override
  State<MachineDetailScreen> createState() => _MachineDetailScreenState();
}

class _MachineDetailScreenState extends State<MachineDetailScreen> {
  late MachineDetailScreenBloc _bloc;

  bool isLike = false;
  bool _isFilterCoresExpanded = false;

  @override
  void initState() {
    super.initState();
    _bloc = BlocProvider.of(context);
    _bloc.add(MachineDetailScreenStartedEvent());
    setState(() {
      //isLike = _bloc.product.isLike == 1;
    });
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MachineDetailScreenBloc, MachineDetailScreenState>(
      builder: _builder,
      listener: _listener,
    );
  }

  void _listener(BuildContext context, MachineDetailScreenState state) {}

  Widget _builder(BuildContext context, MachineDetailScreenState state) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: MyAppBar(
        title: "Chi tiết sản phẩm",
        isBackNavigation: true,
        centerTitle: true,
      ),
      body: LoadingIndicator(
        isLoading: _bloc.isLoading,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildProductHeader(),
            const SizedBox(height: 20),
            _buildMachineInfoCard(),
            if (state is MachineDetailScreenLoadedState &&
                state.orderRentModel.isNotEmpty)
              _buildOrderRentListCard(state.orderRentModel),
            if (state is MachineDetailScreenLoadedState &&
                _bloc.ordersModel.isNotEmpty)
              _buildHistoryFilterCoreCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildProductHeader() {
    String imageUrl =
        (_bloc.order.product!.images == null ||
            _bloc.order.product!.images!.isEmpty ||
            _bloc.order.product!.images![0].link == null)
        ? ""
        : "$protocol${AppConfig.instance.values.apiUrl}${_bloc.order.product!.images![0].link!}";

    final filterCores = _bloc.order.productFilterCoresModel;
    final hasFilterCores = filterCores != null && filterCores.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
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
          if (imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: ImageUtil.loadNetWorkImage(
                url: imageUrl,
                width: 120,
                height: 120,
              ),
            )
          else
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.image_not_supported,
                size: 50,
                color: Colors.grey,
              ),
            ),
          const SizedBox(height: 16),
          Text(
            "${_bloc.order.product!.name}",
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: ColorUtil.bangladeshGreen,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (hasFilterCores) ...[
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),
            InkWell(
              onTap: () {
                setState(() {
                  _isFilterCoresExpanded = !_isFilterCoresExpanded;
                });
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: ColorUtil.bangladeshGreen.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.tune,
                          size: 18,
                          color: ColorUtil.bangladeshGreen,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Danh sách lõi lọc sản phẩm (${filterCores.length})",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: ColorUtil.bangladeshGreen,
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      _isFilterCoresExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: ColorUtil.bangladeshGreen,
                    ),
                  ],
                ),
              ),
            ),
            if (_isFilterCoresExpanded) ...[
              const SizedBox(height: 12),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filterCores.length,
                separatorBuilder: (_, _) => const Divider(height: 16),
                itemBuilder: (context, index) {
                  return _buildProductFilterCoreItem(filterCores[index]);
                },
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildProductFilterCoreItem(ProductFilterCoresModel core) {
    String coreImgUrl = (core.image == null || core.image!.isEmpty)
        ? ""
        : core.image!.startsWith("http")
        ? core.image!
        : "$protocol${AppConfig.instance.values.apiUrl}${core.image!}";

    return Row(
      children: [
        if (coreImgUrl.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: ImageUtil.loadNetWorkImage(
              url: coreImgUrl,
              width: 44,
              height: 44,
            ),
          )
        else
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.filter_alt_outlined,
              size: 22,
              color: Colors.grey,
            ),
          ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                core.name ?? "Lõi lọc",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: ColorUtil.raisinBlack,
                ),
              ),
              if (core.replacementTime != null &&
                  core.replacementTime!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    "Hạn thay thế: ${core.replacementTime}",
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ),
              if (core.startTime != null || core.endTime != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    "Thời gian: ${_formatTimeRange(core.startTime, core.endTime)}",
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty || dateStr.contains("-0001")) {
      return "";
    }
    try {
      final parsed = DateTime.tryParse(dateStr);
      if (parsed != null) {
        return DateFormat("dd/MM/yyyy").format(parsed);
      }
    } catch (_) {}
    return dateStr;
  }

  String _formatTimeRange(String? startTime, String? endTime) {
    final start = _formatDate(startTime);
    final end = _formatDate(endTime);
    if (start.isNotEmpty && end.isNotEmpty) {
      return "$start - $end";
    }
    return start.isNotEmpty ? start : end;
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    Color? valueColor,
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
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

  Widget _buildCard({
    required String title,
    required Widget child,
    IconData? icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
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
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      ),
    );
  }

  Widget _buildMachineInfoCard() {
    return _buildCard(
      title: "Thông tin chung",
      icon: Icons.info_outline,
      child: Column(
        children: [
          _buildInfoRow("Số cấp lọc", _bloc.order.filterCoreLevel ?? "0"),
          _buildInfoRow(
            "Ngày lắp máy",
            _bloc.order.createdAt != null
                ? () {
                    try {
                      final dt = DateTime.parse(
                        _bloc.order.createdAt!,
                      ).toLocal();
                      return DateFormat('dd/MM/yyyy HH:mm:ss').format(dt);
                    } catch (_) {
                      return _bloc.order.createdAt!;
                    }
                  }()
                : "",
          ),
          _buildInfoRow("Vị trí lắp đặt", _bloc.order.address ?? ""),
        ],
      ),
    );
  }

  Widget _buildOrderRentListCard(List<OrderRent> orderRentList) {
    return _buildCard(
      title: "Thông tin máy thuê",
      icon: Icons.handshake_outlined,
      child: ListView.separated(
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: orderRentList.length,
        itemBuilder: (context, index) {
          return _buildOrderRentItem(orderRentList[index]);
        },
        separatorBuilder: (_, _) => const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Divider(color: Color(0xFFEEEEEE)),
        ),
      ),
    );
  }

  Widget _buildOrderRentItem(OrderRent orderRent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: ColorUtil.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            "Mã đơn: ${orderRent.id}",
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: ColorUtil.red,
            ),
          ),
        ),
        _buildInfoRow("Ngày thuê", orderRent.rentalDate ?? ""),
        _buildInfoRow("Ngày kết thúc", orderRent.rentalEndDate ?? ""),
        _buildInfoRow("Thời hạn thuê", orderRent.rentalPeriod ?? "0"),
        _buildInfoRow(
          "Tiền thuê/tháng",
          orderRent.monthlyRent != null
              ? "${NumberFormat("#,##0", "en_US").format(int.parse(orderRent.monthlyRent!))} VND"
              : "0 VND",
        ),
        _buildInfoRow(
          "Tiền cọc",
          orderRent.deposits != null
              ? "${NumberFormat("#,##0", "en_US").format(int.parse(orderRent.deposits!))} VND"
              : "0 VND",
        ),
        _buildInfoRow(
          "Đã thanh toán",
          orderRent.amountPaid != null
              ? "${NumberFormat("#,##0", "en_US").format(int.parse(orderRent.amountPaid!))} VND"
              : "0 VND",
          valueColor: ColorUtil.bangladeshGreen,
        ),
        _buildInfoRow(
          "Công nợ",
          orderRent.dept != null
              ? "${NumberFormat("#,##0", "en_US").format(int.parse(orderRent.dept!))} VND"
              : "0 VND",
          valueColor: ColorUtil.red,
          isBold: true,
        ),
      ],
    );
  }

  Widget _buildHistoryFilterCoreCard() {
    return _buildCard(
      title: "Lịch sử thay lõi",
      icon: Icons.history,
      child: ListView.separated(
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: _bloc.ordersModel.length,
        itemBuilder: _itemBuilder,
        separatorBuilder: (_, _) => const Padding(
          padding: EdgeInsets.symmetric(vertical: 12.0),
          child: Divider(color: Color(0xFFEEEEEE)),
        ),
      ),
    );
  }

  Widget _itemBuilder(BuildContext context, int index) {
    // Decimal heso = Decimal.parse("1000");
    final order = _bloc.ordersModel[index];
    final title =
        "Lần ${_bloc.ordersModel.length - index} - Mã đơn ${order.id}";

    Decimal price = Decimal.parse(order.price ?? "0");
    // Decimal truTichDiem = Decimal.parse(order.truTichDiem ?? "0") * heso;
    // Decimal chietKhau = Decimal.parse(order.chietKhau ?? "0");
    Decimal total = price;
    if (total < Decimal.parse("0")) {
      total = Decimal.parse("0");
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
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
            OutlinedButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  Routes.coreReplacementServiceScreen,
                  arguments: {"orderDetail": order},
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: ColorUtil.brightYellow,
                side: const BorderSide(color: ColorUtil.brightYellow),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                minimumSize: Size.zero,
              ),
              child: const Text(
                "Chi tiết",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildInfoRow("Ngày thay", order.tvInsteadDate ?? ""),
        _buildInfoRow(
          "Thay tiếp theo",
          order.tvNextInsteadDate ?? "",
          valueColor: ColorUtil.red,
          isBold: true,
        ),
        _buildInfoRow("Tổng tiền", total.toString().toVND(), isBold: true),
      ],
    );
  }
}
