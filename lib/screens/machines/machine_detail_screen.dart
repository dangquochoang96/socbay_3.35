import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_format_money_vietnam/flutter_format_money_vietnam.dart';
import 'package:intl/intl.dart';
import 'package:socbay/blocs/machine/machine_detail/machine_detail_bloc.dart';
import 'package:socbay/blocs/machine/machine_detail/machine_detail_event.dart';
import 'package:socbay/blocs/machine/machine_detail/machine_detail_state.dart';
import 'package:socbay/config/app_config.dart';
import 'package:socbay/constants/constants.dart';
import 'package:socbay/data/model/order_rent_model.dart';
import 'package:socbay/routes.dart';
import 'package:socbay/utils/color_util.dart';
import 'package:socbay/utils/image_util.dart';
import 'package:socbay/utils/theme_util.dart';
import 'package:socbay/widgets/button_widget.dart';
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

  Widget separatorBuilder(BuildContext context, int index) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(width: 1.0, color: Colors.black26)),
      ),
    );
  }

  Widget _builder(BuildContext context, MachineDetailScreenState state) {
    return Scaffold(
      appBar: MyAppBar(
        title: "Chi tiết sản phẩm",
        isBackNavigation: true,
        centerTitle: true,
      ),
      body: LoadingIndicator(
        isLoading: _bloc.isLoading,
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: paddingHorizontal,
            vertical: paddingVertical,
          ),
          children: [
            Stack(
              children: [
                Container(
                  padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0.15,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(21),
                    child: ImageUtil.loadNetWorkImage(
                      url:
                          (_bloc.order.product!.images == null ||
                              _bloc.order.product!.images!.isEmpty ||
                              _bloc.order.product!.images![0].link == null)
                          ? ""
                          : "$protocol${AppConfig.instance.values.apiUrl}${_bloc.order.product!.images![0].link!}",
                      width: MediaQuery.of(context).size.width * 0.6,
                      height: MediaQuery.of(context).size.width * 0.6,
                      //height: context.width - paddingHorizontal * 2),
                    ),
                  ),
                ),
              ],
            ),

            Align(
              alignment: Alignment.center,
              child: Container(
                padding: const EdgeInsets.only(top: 10, bottom: 3),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Color(0Xff00bfa5), // Text colour here
                      width: 3.0, // Underline width
                    ),
                  ),
                ),
                child: Text(
                  "${_bloc.order.product!.name}",
                  style: const TextStyle(
                    color: ColorUtil.bangladeshGreen,
                    fontSize: 20,
                    fontWeight: MyFontWeight.bold,
                  ),
                ),
              ),
            ),
            const Divider(color: Colors.grey, thickness: 1, height: 40),
            // const Text(
            //   "Mô tả:",
            //   style: TextStyle(
            //       color: ColorUtil.bangladeshGreen,
            //       fontWeight: MyFontWeight.bold,
            //       fontSize: 18),
            // ),
            Table(
              columnWidths: const {1: FlexColumnWidth(1)},
              children: [
                TableRow(
                  children: [
                    const Text(
                      "Số cấp lọc: ",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(_bloc.order.filterCoreLevel ?? "0"),
                  ],
                ),
                TableRow(
                  children: [
                    const Text(
                      "Ngày lắp máy: ",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(_bloc.order.createdAt ?? ""),
                  ],
                ),
                TableRow(
                  children: [
                    const Text(
                      "Vị trí lắp đặt: ",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(_bloc.order.address ?? ""),
                  ],
                ),
              ],
            ),
            if (state is MachineDetailScreenLoadedState &&
                state.orderRentModel.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 10,
                ),
                child: Container(
                  alignment: Alignment.center,
                  child: const Text(
                    "Thông tin máy thuê",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: ColorUtil.red,
                    ),
                  ),
                ),
              ),
            if (state is MachineDetailScreenLoadedState)
              _buildOrderRentList(state.orderRentModel),
            const Divider(color: Colors.grey, thickness: 1, height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: Container(
                alignment: Alignment.center,
                child: const Text(
                  "Lịch sử thay lõi",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: ColorUtil.red,
                  ),
                ),
              ),
            ),
            _buildHistoryFilterCore(),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderRentList(List<OrderRent> orderRentList) {
    return ListView.separated(
      padding: const EdgeInsets.only(left: 10.0),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: orderRentList.length,
      itemBuilder: (context, index) {
        return _buildOrderRentItem(orderRentList[index]);
      },
      separatorBuilder: separatorBuilder,
    );
  }

  // Function to build a single order rent item
  Widget _buildOrderRentItem(OrderRent orderRent) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              "Mã đơn thuê ${orderRent.id}",
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 3.0),
          child: Table(
            columnWidths: const {1: FlexColumnWidth(1)},
            children: [
              TableRow(
                children: [
                  const Text(
                    "Tiền thuê/tháng: ",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                  ),
                  Text(
                    orderRent.monthlyRent != null
                        ? "${NumberFormat("#,##0", "en_US").format(int.parse(orderRent.monthlyRent!))} VND"
                        : "0",
                  ),
                ],
              ),
              TableRow(
                children: [
                  const Text(
                    "Thời hạn thuê: ",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                  ),
                  Text(orderRent.rentalPeriod ?? "0"),
                ],
              ),
              TableRow(
                children: [
                  const Text(
                    "Tiền cọc: ",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                  ),
                  Text(
                    orderRent.deposits != null
                        ? "${NumberFormat("#,##0", "en_US").format(int.parse(orderRent.deposits!))} VND"
                        : "0",
                  ),
                ],
              ),
              TableRow(
                children: [
                  const Text(
                    "Đã thanh toán: ",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                  ),
                  Text(
                    orderRent.amountPaid != null
                        ? "${NumberFormat("#,##0", "en_US").format(int.parse(orderRent.amountPaid!))} VND"
                        : "0",
                  ),
                ],
              ),
              TableRow(
                children: [
                  const Text(
                    "Công nợ: ",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                  ),
                  Text(
                    orderRent.dept != null
                        ? "${NumberFormat("#,##0", "en_US").format(int.parse(orderRent.dept!))} VND"
                        : "0",
                  ),
                ],
              ),
              TableRow(
                children: [
                  const Text(
                    "Ngày thuê: ",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                  ),
                  Text(orderRent.rentalDate ?? ""),
                ],
              ),
              TableRow(
                children: [
                  const Text(
                    "Ngày kết thúc thuê: ",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                  ),
                  Text(orderRent.rentalEndDate ?? ""),
                ],
              ),
            ],
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
              itemCount: _bloc.ordersModel.length,
              itemBuilder: _itemBuilder,
              separatorBuilder: _separateView,
            ),
            const SizedBox(height: 10),
          ],
        ),
      ],
    );
  }

  Widget _itemBuilder(BuildContext context, int index) {
    Decimal heso = Decimal.parse("1000");
    return Wrap(
      spacing: 8.0, // gap between adjacent chips
      runSpacing: 4.0, // gap between lines
      direction: Axis.horizontal, // main axis (rows or columns)
      children: [
        Column(
          children: [
            Row(
              children: [
                Text(
                  "Lịch sử lần thay lõi ${_bloc.ordersModel.length - index} - Mã đơn ${_bloc.ordersModel[index].id}",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
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
                columnWidths: const {1: FlexColumnWidth(1)},
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
                      Text(_bloc.ordersModel[index].tvInsteadDate ?? ""),
                    ],
                  ),
                  TableRow(
                    children: [
                      const Text(
                        "Ngày thay tiếp theo: ",
                        style: TextStyle(
                          color: ColorUtil.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                      Text(
                        _bloc.ordersModel[index].tvNextInsteadDate ?? "",
                        style: const TextStyle(
                          color: ColorUtil.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
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
                        ((Decimal.parse(_bloc.ordersModel[index].price ?? "0") -
                                        Decimal.parse(
                                              _bloc
                                                      .ordersModel[index]
                                                      .truTichDiem ??
                                                  "0",
                                            ) *
                                            heso -
                                        Decimal.parse(
                                          _bloc.ordersModel[index].chietKhau ??
                                              "0",
                                        )) >
                                    Decimal.parse("0")
                                ? (Decimal.parse(
                                        _bloc.ordersModel[index].price ?? "0",
                                      ) -
                                      Decimal.parse(
                                            _bloc
                                                    .ordersModel[index]
                                                    .truTichDiem ??
                                                "0",
                                          ) *
                                          heso -
                                      Decimal.parse(
                                        _bloc.ordersModel[index].chietKhau ??
                                            "0",
                                      ))
                                : 0)
                            .toString()
                            .toVND(),
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
                  arguments: {"orderDetail": _bloc.ordersModel[index]},
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

  Widget _separateView(BuildContext context, int index) {
    return const SizedBox(height: 8);
  }
}
