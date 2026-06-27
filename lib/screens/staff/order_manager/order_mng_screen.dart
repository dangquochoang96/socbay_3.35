import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_format_money_vietnam/flutter_format_money_vietnam.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:socbay/blocs/staff/order/order_manager_bloc.dart';
import 'package:socbay/blocs/staff/order/order_manager_event.dart';
import 'package:socbay/blocs/staff/order/order_manager_state.dart';
import 'package:socbay/constants/constants.dart';
import 'package:socbay/data/model/order_detail_model.dart';
import 'package:socbay/data/model/staff_order_detail_model.dart';
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

  @override
  void initState() {
    _bloc = BlocProvider.of(context);
    var startInitTime = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      1,
    ).toString();
    var endInitTime = DateTime.now().add(
      const Duration(seconds: (23 * 60 + 59) * 60),
    );
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
            // Navigator.pushReplacementNamed(context, Routes.root);
            Navigator.pop(context);
          },
        ),
        body: RefreshIndicator(
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

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _datetimeRange(),
        const SizedBox(height: 10),
        _buildStatsGrid(),
        const Padding(
          padding: EdgeInsets.only(bottom: 12.0, top: 4.0),
          child: Text(
            'Danh sách đơn hàng',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ColorUtil.raisinBlack,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String? status) {
    String text = 'Thay lõi';
    Color bgColor = ColorUtil.green.withValues(alpha: 0.1);
    Color textColor = ColorUtil.green;

    if (status == '0') {
      text = 'Lắp máy';
      bgColor = ColorUtil.brightYellow.withValues(alpha: 0.1);
      textColor = ColorUtil.brightYellow;
    } else if (status == '1') {
      text = 'Vệ sinh';
      bgColor = Colors.blue.withValues(alpha: 0.1);
      textColor = Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
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

  Widget _buildOrderCard(BuildContext context, StaffOrderDetailModel order) {
    Decimal heso = Decimal.parse("1000");
    var finalPrice =
        (Decimal.parse(order.price ?? "0") -
        Decimal.parse(order.truTichDiem ?? "0") * heso -
        Decimal.parse(order.chietKhau ?? "0"));
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
                _buildStatusBadge(order.status),
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
