import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:socbay/application.dart';
import 'package:socbay/blocs/history/history_screen_bloc.dart';
import 'package:socbay/blocs/history/history_screen_state.dart';
import 'package:socbay/config/app_config.dart';
import 'package:socbay/constants/constants.dart';
import 'package:socbay/data/model/order_model.dart';
import 'package:socbay/data/model/task_model.dart';
import 'package:socbay/routes.dart';
import 'package:socbay/utils/color_util.dart';
import 'package:socbay/utils/context_extension.dart';
import 'package:socbay/utils/image_util.dart';
import 'package:socbay/widgets/button_widget.dart';
import 'package:socbay/widgets/loading_indicator.dart';
import 'package:socbay/widgets/my_app_bar.dart';
import 'package:socbay/widgets/text_field_default.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../blocs/historyid/historyid_screen_bloc.dart';
import '../../blocs/historyid/historyid_screen_event.dart';

class HistoryidScreen extends StatefulWidget {
  const HistoryidScreen({super.key});

  @override
  State<HistoryidScreen> createState() => _HistoryidScreenState();
}

class _HistoryidScreenState extends State<HistoryidScreen>
    with TickerProviderStateMixin {
  late HistoryidScreenBloc _bloc;
  late TabController _tabHistoryController;
  late TextEditingController _feedbackController;
  @override
  void initState() {
    _bloc.add(HistoryidScreenTabPressEvent(1));
    _tabHistoryController = TabController(
      length: 2,
      initialIndex: 1,
      vsync: this,
    );
    _tabHistoryController.addListener(() {
      if (_tabHistoryController.index != _tabHistoryController.previousIndex) {
        _bloc.add(HistoryidScreenTabPressEvent(_tabHistoryController.index));
      }
    });
    _feedbackController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    _tabHistoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _bloc = BlocProvider.of<HistoryidScreenBloc>(context);

    return BlocConsumer<HistoryScreenBloc, HistoryScreenState>(
      builder: _builder,
      listener: _listener,
    );
  }

  void _listener(BuildContext context, HistoryScreenState state) {
    if (state is BookingDeleteSuccessState) {
      context.showSnackBar("Hủy thành công!");
    }
    if (state is BookingDeleteErrorState) {
      context.showSnackBar("Hủy thắt bại!");
    }
    if (state is HistoryScreenInitialState) {
      setState(() {});
    }
  }

  Widget _builder(BuildContext context, HistoryScreenState state) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: "history_screen",
        backgroundColor: ColorUtil.brightYellow,
        shape: const CircleBorder(
          side: BorderSide(color: Colors.white, width: 3.0),
        ),
        tooltip: "Thêm công việc",
        onPressed: () {
          Navigator.pushNamed(
            context,
            App.instance.userApp?.isUserCustomer() == true
                ? Routes.serviceScreen
                : App.instance.userApp?.isUserRole() == true
                ? Routes.staffServiceScreen
                : Routes.staffServiceScreenSale,
            arguments: {"listService": [], "index": ""},
          );
        },
        child: const Icon(Icons.add),
      ),
      appBar: MyAppBar(title: "Lịch sử", isBackNavigation: false),
      body: LoadingIndicator(
        isLoading: _bloc.isLoading,
        child: RefreshIndicator(
          onRefresh: () async {
            _bloc.add(
              HistoryidScreenTabPressEvent(_tabHistoryController.index),
            );
          },
          child: Column(
            children: [
              TabBar(
                controller: _tabHistoryController,
                indicatorColor: ColorUtil.bangladeshGreen,
                tabs: [
                  _buildTab('Lịch sử đặt lịch'),
                  _buildTab('Nhật ký thay lõi'),
                ],
              ),
              Expanded(
                child: IndexedStack(
                  index: _tabHistoryController.index,
                  children: [_buildServiceHistory(), _buildProductsHistory()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Tab _buildTab(text) {
    return Tab(
      height: 36,
      child: Text(
        text,
        style: const TextStyle(
          color: ColorUtil.bangladeshGreen,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildServiceHistory() {
    if (_bloc.lstBooking.isEmpty) {
      return const Text('Khách hàng chưa đặt lịch');
    }
    return ListView.separated(
      itemBuilder: _buildItemServiceHistory,
      separatorBuilder: separatorBuilder,
      itemCount: _bloc.lstBooking.length,
    );
  }

  Widget _buildProductsHistory() {
    if (_bloc.lstMachine.isEmpty) {
      return const Text('Khách hàng chưa thay lõi');
    }
    return ListView.separated(
      // reverse: true,
      itemBuilder: _buildItemMachineInUse,
      separatorBuilder: separatorBuilder,
      itemCount: _bloc.lstMachine.length,
    );
  }

  Widget separatorBuilder(BuildContext context, int index) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(width: 1.0, color: Colors.black26)),
      ),
    );
  }

  Widget _buildItemServiceHistory(BuildContext context, int index) {
    int reversedIndex = _bloc.lstMachine.length - 1 - index;
    if (reversedIndex < 0 || reversedIndex >= _bloc.lstBooking.length) {
      return Container();
    }
    TaskModel taskModel = _bloc.lstBooking[reversedIndex];
    final dataFormat = _formatDatetime(taskModel.timeStart);
    return _buildServiceHistoryCard(taskModel, dataFormat);
  }

  Widget _buildServiceHistoryCard(TaskModel taskModel, String dataFormat) {
    final canCancel =
        taskModel.status == '1' ||
        taskModel.status == '2' ||
        taskModel.status == '5';
    final staffPhone = taskModel.staff?.phone ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: paddingHorizontal,
        vertical: 8,
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _detailTask(taskModel),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: ColorUtil.bangladeshGreen.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.event_note_outlined,
                              color: ColorUtil.bangladeshGreen,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Mã dịch vụ: DV_${taskModel.id}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: ColorUtil.raisinBlack,
                                  ),
                                  maxLines: 2,
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  taskModel.name ?? '',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[700],
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: _buildHistoryStatusBadge(
                                    taskModel.getStatus(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24, color: Color(0xFFEFEFEF)),
                _buildHistoryInfoRow(
                  Icons.access_time,
                  'Thời gian',
                  dataFormat,
                  valueColor: ColorUtil.red,
                  isBoldValue: true,
                ),
                const SizedBox(height: 10),
                _buildHistoryInfoRow(
                  Icons.person_outline,
                  'K\u1ef9 thu\u1eadt vi\u00ean',
                  taskModel.staff?.username ?? '',
                ),
                const SizedBox(height: 10),
                _buildHistoryInfoRow(
                  Icons.phone_outlined,
                  'SĐT KTV',
                  staffPhone.isEmpty ? 'Chưa có' : staffPhone,
                  valueColor: staffPhone.isEmpty
                      ? Colors.grey[600]
                      : ColorUtil.bangladeshGreen,
                  isBoldValue: staffPhone.isNotEmpty,
                  onTap: staffPhone.isEmpty
                      ? null
                      : () => launchUrl(Uri.parse('tel:$staffPhone')),
                ),
                if (canCancel) ...[
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton.icon(
                      onPressed: () => _cancelTask(taskModel),
                      icon: const Icon(Icons.cancel_outlined, size: 18),
                      label: const Text('H\u1ee7y l\u1ecbch'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ColorUtil.red,
                        side: const BorderSide(color: ColorUtil.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: ColorUtil.bangladeshGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: ColorUtil.bangladeshGreen,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildHistoryInfoRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
    bool isBoldValue = false,
    VoidCallback? onTap,
  }) {
    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        SizedBox(
          width: 96,
          child: Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: valueColor ?? ColorUtil.raisinBlack,
              fontWeight: isBoldValue ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ),
      ],
    );

    if (onTap == null) {
      return content;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: content,
      ),
    );
  }

  Widget _buildItemMachineInUse(BuildContext context, int index) {
    OrderModel machine = _bloc.lstMachine[index];
    var dataFormat = _formatDatetime(machine.createdAt);
    return ButtonWidget(
      onTap: () {
        _detailMachine(machine);
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.only(
          left: MediaQuery.of(context).size.width * 0.02,
          right: MediaQuery.of(context).size.width * 0.02,
          bottom: 10,
        ),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.black12, width: 1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.2,
                  decoration: BoxDecoration(
                    border: Border.all(width: 3, color: Colors.black12),
                  ),
                  child: ImageUtil.loadNetWorkImage(
                    url: machine.product!.images?[0].link == null
                        ? ""
                        : "$protocol${AppConfig.instance.values.apiUrl}${machine.product!.images![0].link!}",
                    height: MediaQuery.of(context).size.width * 0.16,
                    width: MediaQuery.of(context).size.width * 0.16,
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0.02,
                    top: MediaQuery.of(context).size.width * 0.01,
                  ),
                  width: MediaQuery.of(context).size.width * 0.74,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${machine.product!.name}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: ColorUtil.raisinBlack,
                          fontSize: 16,
                        ),
                      ),
                      Wrap(
                        //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        spacing: 8.0, // gap between adjacent chips
                        runSpacing: 4.0, // gap between lines
                        direction:
                            Axis.horizontal, // main axis (rows or columns)
                        children: [
                          Align(
                            alignment: Alignment.topLeft,
                            child: Container(
                              padding: EdgeInsets.only(
                                top: MediaQuery.of(context).size.width * 0.01,
                              ),
                              child: (RichText(
                                softWrap: true,
                                maxLines: 3,
                                text: TextSpan(
                                  children: [
                                    const TextSpan(
                                      text: 'Model: ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: ColorUtil.bangladeshGreen,
                                        decorationThickness: 1,
                                        fontSize: 13,
                                      ),
                                    ),
                                    TextSpan(
                                      text: machine.product!.name ?? '',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.normal,
                                        color: ColorUtil.raisinBlack,
                                        decorationThickness: 1,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                            ),
                          ),
                          Align(
                            alignment: Alignment.topRight,
                            child: Container(
                              padding: EdgeInsets.only(
                                top: MediaQuery.of(context).size.width * 0.01,
                              ),
                              child: (RichText(
                                softWrap: true,
                                maxLines: 3,
                                text: TextSpan(
                                  children: [
                                    const TextSpan(
                                      text: 'Ngày mua: ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: ColorUtil.bangladeshGreen,
                                        decorationThickness: 1,
                                        fontSize: 13,
                                      ),
                                    ),
                                    TextSpan(
                                      text: dataFormat,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.normal,
                                        color: ColorUtil.raisinBlack,
                                        decorationThickness: 1,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                            ),
                          ),
                        ],
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

  Future<void> _cancelTask(TaskModel taskModel) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Vui lòng cho biết lý do bạn hủy dịch vụ',
            textAlign: TextAlign.center,
          ),
          content: TextFieldDefault(
            controller: _feedbackController,
            maxLines: 5,
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildButtonDialog(
                  isPositive: false,
                  text: 'Hủy',
                  action: () {
                    Navigator.pop(context);
                    _feedbackController.clear();
                  },
                ),
                const SizedBox(width: 16),
                _buildButtonDialog(
                  isPositive: true,
                  text: 'Gửi',
                  action: () {
                    _bloc.add(
                      BookingDeleteidTaskEvent(
                        taskModel.id ?? 0,
                        taskModel.name!,
                        _feedbackController.text,
                      ),
                    );
                    Navigator.pop(context);
                    _feedbackController.clear();
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

  void _detailTask(TaskModel taskModel) async {
    Navigator.pushNamed(
      context,
      Routes.detailBookingScreen,
      arguments: {'id': taskModel.id},
    );
  }

  void _detailMachine(OrderModel orderModel) async {
    Navigator.pushNamed(context, Routes.machineDetail, arguments: orderModel);
  }

  String _formatDatetime(String? dateTimeString) {
    try {
      var dateTime = dateTimeString ?? DateTime.now().toString();
      DateTime getDateTime = DateTime.parse(dateTime);
      var output = DateFormat('dd/MM/yyyy HH:mm:ss').format(getDateTime);
      return output.toString();
    } catch (ex) {
      rethrow;
    }
  }
}
