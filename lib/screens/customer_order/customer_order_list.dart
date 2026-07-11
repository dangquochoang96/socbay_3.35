import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_format_money_vietnam/flutter_format_money_vietnam.dart';
import 'package:intl/intl.dart';
import 'package:socbay/application.dart';
import 'package:socbay/blocs/customer_order/customer_order_payment_bloc.dart';
import 'package:socbay/blocs/customer_order/customer_order_payment_event.dart';
import 'package:socbay/blocs/customer_order/customer_order_payment_state.dart';
import 'package:socbay/data/event_bus/event_bus_event.dart';
import 'package:socbay/data/model/order_detail_model.dart';
import 'package:socbay/routes.dart';
import 'package:socbay/utils/color_util.dart';
import 'package:socbay/widgets/my_app_bar.dart';

class CustomerOrderListScreen extends StatefulWidget {
  const CustomerOrderListScreen({super.key});

  @override
  State<CustomerOrderListScreen> createState() =>
      _CustomerOrderListScreenState();
}

class _CustomerOrderListScreenState extends State<CustomerOrderListScreen> {
  late CustomerOrderPaymentBloc _bloc;
  final ScrollController _scrollController = ScrollController();
  StreamSubscription? _eventBusSubscription;

  @override
  void initState() {
    super.initState();
    _bloc = BlocProvider.of<CustomerOrderPaymentBloc>(context);
    _bloc.add(const CustomerOrderPaymentStartEvent());

    _scrollController.addListener(_onScroll);

    // Listen to EventBus for updating order list when payment succeeds
    _eventBusSubscription = App.instance.eventBus
        .on<EventBusReloadOrderPaymentsEvent>()
        .listen((event) {
          _bloc.add(const CustomerOrderPaymentStartEvent(isRefresh: true));
        });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _eventBusSubscription?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _bloc.add(CustomerOrderPaymentLoadMoreEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: MyAppBar(title: "Quản lý công nợ & Thanh toán"),
      body: BlocBuilder<CustomerOrderPaymentBloc, CustomerOrderPaymentState>(
        builder: (context, state) {
          if (state is CustomerOrderPaymentLoading) {
            return const Center(
              child: CircularProgressIndicator(color: ColorUtil.green),
            );
          }

          if (state is CustomerOrderPaymentError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: ColorUtil.red,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: ColorUtil.raisinBlack,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        _bloc.add(const CustomerOrderPaymentStartEvent());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorUtil.green,
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

          if (state is CustomerOrderPaymentLoaded) {
            final filteredOrders = _filterOrders(
              state.orders,
              state.filterStatus,
            );

            return RefreshIndicator(
              onRefresh: () async {
                _bloc.add(
                  const CustomerOrderPaymentStartEvent(isRefresh: true),
                );
              },
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // Statistics Panel
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _buildStatisticsGrid(state.statistics),
                    ),
                  ),

                  // Filter Chips
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: _buildFilterTabs(state.filterStatus),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 16)),

                  // Order List
                  if (filteredOrders.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "Không tìm thấy đơn hàng nào",
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index < filteredOrders.length) {
                            return _buildOrderCard(filteredOrders[index]);
                          } else {
                            return const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: ColorUtil.green,
                                ),
                              ),
                            );
                          }
                        },
                        childCount:
                            filteredOrders.length + (state.hasMore ? 1 : 0),
                      ),
                    ),

                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  int _getOrderPaymentStatus(dynamic item) {
    final rawStatus = item['overall_payment_status'];
    if (rawStatus != null) {
      final parsed = int.tryParse(rawStatus.toString());
      if (parsed != null) {
        return parsed;
      }
    }

    final orderPayment = item['order_payment'] as List?;
    if (orderPayment == null || orderPayment.isEmpty) {
      return 1; // Empty order_payment list means paid (status 1)
    }

    bool hasUnpaid = false;
    bool hasPending = false;
    for (final p in orderPayment) {
      if (p is Map) {
        final pStatus = p['payment_status']?.toString();
        if (pStatus == '0') {
          hasUnpaid = true;
        } else if (pStatus == '2') {
          hasPending = true;
        }
      }
    }
    if (hasUnpaid) return 0;
    if (hasPending) return 2;
    return 1;
  }

  // Filter local logic matching user rules
  List<dynamic> _filterOrders(List<dynamic> orders, int filterStatus) {
    if (filterStatus == -1) return orders;

    return orders.where((item) {
      final status = _getOrderPaymentStatus(item);
      return status == filterStatus;
    }).toList();
  }

  Widget _buildStatisticsGrid(Map<String, dynamic> stats) {
    final totalOrders = stats['total_orders'] ?? 0;
    final totalPrice =
        double.tryParse(stats['total_orders_price']?.toString() ?? '0') ?? 0;
    final totalPaid =
        double.tryParse(stats['total_paid_amount']?.toString() ?? '0') ?? 0;
    final totalDebt =
        double.tryParse(stats['total_debt']?.toString() ?? '0') ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Tổng quan công nợ",
          style: TextStyle(
            color: ColorUtil.raisinBlack,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildStatCard(
              title: "Tổng số đơn",
              value: "$totalOrders đơn",
              icon: Icons.assignment_outlined,
              color: const Color(0xFF2563EB),
              bgColor: const Color(0xFFEFF6FF),
            ),
            _buildStatCard(
              title: "Tổng tiền hàng",
              value: totalPrice.toInt().toVND(),
              icon: Icons.payments_outlined,
              color: const Color(0xFF7C3AED),
              bgColor: const Color(0xFFF5F3FF),
            ),
            _buildStatCard(
              title: "Đã thanh toán",
              value: totalPaid.toInt().toVND(),
              icon: Icons.check_circle_outline_rounded,
              color: const Color(0xFF16A34A),
              bgColor: const Color(0xFFF0FDF4),
            ),
            _buildStatCard(
              title: "Còn nợ",
              value: totalDebt.toInt().toVND(),
              icon: Icons.info_outline_rounded,
              color: totalDebt > 0 ? ColorUtil.red : const Color(0xFF64748B),
              bgColor: totalDebt > 0
                  ? const Color(0xFFFEF2F2)
                  : const Color(0xFFF8FAFC),
              textColor: totalDebt > 0 ? ColorUtil.red : null,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
    Color? textColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: ColorUtil.spanishGray,
                  fontSize: 12,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              color: textColor ?? ColorUtil.raisinBlack,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs(int currentFilter) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildFilterChip(
            label: "Tất cả",
            value: -1,
            active: currentFilter == -1,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: "Chưa thanh toán",
            value: 0,
            active: currentFilter == 0,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: "Chờ xác nhận",
            value: 2,
            active: currentFilter == 2,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: "Đã thanh toán",
            value: 1,
            active: currentFilter == 1,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required int value,
    required bool active,
  }) {
    return GestureDetector(
      onTap: () {
        _bloc.add(CustomerOrderPaymentFilterChangedEvent(value));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF2563EB) : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: active ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : ColorUtil.spanishGray,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(dynamic order) {
    final orderId = order['id'];
    final price = double.tryParse(order['price']?.toString() ?? '0') ?? 0;
    final totalPaid =
        double.tryParse(order['total_paid']?.toString() ?? '0') ?? 0;
    final debt = double.tryParse(order['debt']?.toString() ?? '0') ?? 0;
    final note = order['ghichu'];
    final createdAt = order['created_at'];

    final paymentStatus = _getOrderPaymentStatus(order);

    String formattedDate = '';
    if (createdAt != null) {
      try {
        final parsedDate = DateTime.parse(createdAt);
        formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(parsedDate);
      } catch (_) {
        formattedDate = createdAt.toString();
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          // Construct OrderDetailModel from order JSON
          final orderDetail = OrderDetailModel.fromJson(
            Map<String, dynamic>.from(order),
          );
          Navigator.pushNamed(
            context,
            Routes.coreReplacementServiceScreen,
            arguments: {"orderDetail": orderDetail},
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Đơn hàng #$orderId",
                    style: const TextStyle(
                      color: ColorUtil.raisinBlack,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  _buildPaymentChip(paymentStatus),
                ],
              ),
              if (formattedDate.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  formattedDate,
                  style: const TextStyle(
                    color: ColorUtil.spanishGray,
                    fontSize: 12,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              const Divider(color: Color(0xFFF1F5F9), height: 1),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildAmountCol("Giá trị", price.toInt().toVND()),
                  _buildAmountCol(
                    "Đã thanh toán",
                    totalPaid.toInt().toVND(),
                    color: const Color(0xFF16A34A),
                  ),
                  _buildAmountCol(
                    "Còn nợ",
                    debt.toInt().toVND(),
                    color: debt > 0 ? ColorUtil.red : Colors.grey,
                  ),
                ],
              ),
              if (note != null && note.toString().trim().isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "Ghi chú: ${note.toString()}",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "Xem chi tiết",
                    style: TextStyle(
                      color: Color(0xFF2563EB),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 12,
                    color: Color(0xFF2563EB),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentChip(int status) {
    String text;
    Color textColor;
    Color bgColor;

    if (status == 1) {
      text = "Đã thanh toán";
      textColor = const Color(0xFF15803D);
      bgColor = const Color(0xFFDCFCE7);
    } else if (status == 2) {
      text = "Chờ xác nhận";
      textColor = const Color(0xFFB45309);
      bgColor = const Color(0xFFFEF3C7);
    } else {
      text = "Chưa thanh toán";
      textColor = const Color(0xFFB91C1C);
      bgColor = const Color(0xFFFEE2E2);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildAmountCol(String title, String amount, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(color: ColorUtil.spanishGray, fontSize: 11),
        ),
        const SizedBox(height: 4),
        Text(
          amount,
          style: TextStyle(
            color: color ?? ColorUtil.raisinBlack,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
