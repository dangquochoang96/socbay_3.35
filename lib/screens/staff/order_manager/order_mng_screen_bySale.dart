import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_format_money_vietnam/flutter_format_money_vietnam.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:socbay/blocs/staff/order/order_manager_event.dart';
import 'package:socbay/blocs/staff/order/order_manager_state.dart';
import 'package:socbay/constants/constants.dart';
import 'package:socbay/data/model/order_detail_model.dart';
import 'package:socbay/routes.dart';
import 'package:socbay/utils/color_util.dart';
import 'package:socbay/widgets/button_widget.dart';
import 'package:socbay/widgets/date_range_form_field.dart';
import 'package:socbay/widgets/loading_indicator.dart';
import 'package:socbay/widgets/my_app_bar.dart';

import '../../../blocs/staff/order/order_manager_bloc_bySale.dart';

class OrderManagerScreenBySale extends StatefulWidget {
  const OrderManagerScreenBySale({super.key});

  @override
  State<OrderManagerScreenBySale> createState() => _OrderManagerScreenState();
}

class _OrderManagerScreenState extends State<OrderManagerScreenBySale> {
  late OrderManagerBlocBySale _bloc;
  DateTimeRange? myDateRange;
  @override
  void initState() {
    _bloc = BlocProvider.of(context);
    //_bloc.add(const OrderManagerListEvent());
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
      ),
    );
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OrderManagerBlocBySale, OrderManagerState>(
      builder: _builder,
      listener: _listener,
    );
  }

  void _listener(BuildContext context, OrderManagerState state) {}

  Widget _builder(BuildContext context, OrderManagerState state) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: MyAppBar(
          title: "Quản lý đơn hàng",
          isBackNavigation: true,
          onBack: () async {
            Navigator.pushReplacementNamed(context, Routes.root);
          },
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            final now = DateTime.now();

            var start = DateTime(now.year, now.month, 1).toString();
            var end = DateTime.now();
            _bloc.add(
              OrderManagerListEvent(
                start: start,
                end: end
                    .add(const Duration(seconds: (23 * 60 + 59) * 60))
                    .toString(),
              ),
            );
          },
          child: LoadingIndicator(
            isLoading: _bloc.isLoading,
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: paddingHorizontal,
                vertical: paddingVertical,
              ),
              shrinkWrap: true,
              children: [
                Center(widthFactor: 2.0, child: _datetimeRange()),
                IntrinsicHeight(
                  //wrap Row with this, otherwise, vertical divider will not display
                  child: Row(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.35,
                        child: Table(
                          columnWidths: const {
                            0: FlexColumnWidth(2),
                            1: FlexColumnWidth(0.5),
                          },
                          children: [
                            _buildTableRow(
                              title: 'Tổng đơn',
                              content: _bloc.totalOrderAll.toString(),
                              isHighlight: true,
                            ),
                            _buildTableRow(
                              title: 'Đơn phát sinh',
                              content: _bloc.totalDonThayLoi.toString(),
                              isHighlight: true,
                            ),
                          ],
                        ),
                      ),
                      const VerticalDivider(
                        color: Color(0xFFD6D6D6), //color of divider
                        width: 1, //width space of divider
                        thickness: 2, //thickness of divier line
                        indent: 10, //Spacing at the top of divider.
                        endIndent: 0, //Spacing at the bottom of divider.
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.55,
                        child: Table(
                          columnWidths: const {
                            0: FlexColumnWidth(1),
                            1: FlexColumnWidth(1),
                          },
                          children: [
                            _buildTableRow(
                              title: 'Đơn vệ sinh',
                              content: _bloc.totalDonVeSinh.toString(),
                              isHighlight: true,
                            ),
                            _buildTableRow(
                              title: 'Đơn lắp máy',
                              content: _bloc.totalDonLapMay.toString(),
                              isHighlight: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Center(
                  heightFactor: 2.0,
                  child: Text(
                    'Tổng doanh thu: ${(_bloc.totalPriceAll).toInt().toVND()}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: ColorUtil.bangladeshGreen,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: const Divider(
                      color: Color(0xFFD6D6D6),
                      thickness: 2,
                      height: 30,
                    ),
                  ),
                ),
                _buildHistoryFilterCore(),
              ],
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
            ),
          );
        });
      },
    );
  }

  TableRow _buildTableRow({
    required String title,
    required String? content,
    required bool isHighlight,
  }) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: Text(
            title,
            style: const TextStyle(
              color: ColorUtil.raisinBlack,
              fontWeight: FontWeight.bold,
              height: 1.5,
            ),
          ),
        ),
        Text(
          "$content",
          style: TextStyle(
            color: isHighlight ? ColorUtil.bangladeshGreen : Colors.black,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryFilterCore() {
    return Wrap(
      spacing: 8.0, // gap between adjacent chips
      runSpacing: 4.0, // gap between lines
      direction: Axis.horizontal, // main axis (rows or columns)
      children: [
        Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListView.separated(
              padding: const EdgeInsets.only(left: 10.0),
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: _bloc.staffLstOrders.length,
              itemBuilder: _itemBuilder,
              separatorBuilder: _separateView,
            ),
            const SizedBox(height: 10),
          ],
        ),
      ],
    );
  }

  Widget _separateView(BuildContext context, int index) {
    return const SizedBox(height: 8);
  }

  Widget _itemBuilder(BuildContext context, int index) {
    Decimal heso = Decimal.parse("1000");
    return Wrap(
      // onTap: () {
      //   Navigator.pushNamed(context, Routes.coreReplatementServiceScreen,
      //       arguments: {"orderDetail":_bloc.ordersModel[index]});
      // },
      spacing: 8.0, // gap between adjacent chips
      runSpacing: 4.0, // gap between lines
      direction: Axis.horizontal, // main axis (rows or columns)
      children: [
        Column(
          children: [
            Row(
              children: [
                Text(
                  "Mã đơn hàng: MB_${_bloc.staffLstOrders[index].id}",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 30,
                vertical: 3.0,
              ),
              child: Table(
                columnWidths: const {0: FlexColumnWidth(2)},
                children: [
                  TableRow(
                    children: [
                      const Text(
                        "Ngày thay: ",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        _bloc.staffLstOrders[index].tvInsteadDate?.substring(
                              0,
                              10,
                            ) ??
                            "",
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      const Text(
                        "Ngày thay tiếp theo: ",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        _bloc.staffLstOrders[index].tvNextInsteadDate
                                ?.substring(0, 10) ??
                            "",
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      const Text(
                        "Tổng tiền: ",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        (Decimal.parse(
                                  _bloc.staffLstOrders[index].price ?? "0",
                                ) -
                                Decimal.parse(
                                      _bloc.staffLstOrders[index].truTichDiem ??
                                          "0",
                                    ) *
                                    heso -
                                Decimal.parse(
                                  _bloc.staffLstOrders[index].chietKhau ?? "0",
                                ))
                            .toBigInt()
                            .toVND(),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      const Text(
                        "Đánh giá: ",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      RatingBarIndicator(
                        rating: _bloc.staffLstOrders[index].rate != null
                            ? double.parse(_bloc.staffLstOrders[index].rate!)
                            : 0.0,
                        direction: Axis.horizontal,
                        unratedColor: Colors.amber.withAlpha(60),
                        itemCount: 5,
                        itemSize: 13.0,
                        itemPadding: const EdgeInsets.symmetric(
                          horizontal: 4.0,
                        ),
                        itemBuilder: (context, _) =>
                            const Icon(Icons.star, color: Colors.amber),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ButtonWidget(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  Routes.coreReplacementServiceScreen,
                  arguments: {
                    "orderDetail": OrderDetailModel(
                      id: _bloc.staffLstOrders[index].id,
                    ),
                  },
                );
              },
              padding: const EdgeInsets.all(6.0),
              borderRadius: BorderRadius.circular(10.0),
              color: ColorUtil.brightYellow,
              child: const Text(
                "Xem chi tiết >>",
                style: TextStyle(color: ColorUtil.white),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                padding: const EdgeInsets.only(top: 5.0),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(width: 0.3, color: Colors.black26),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
