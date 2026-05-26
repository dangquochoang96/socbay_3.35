import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:socbay/application.dart';
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

import '../../blocs/historyidC/historyidC_screen_bloc.dart';
import '../../blocs/historyidC/historyidC_screen_event.dart';
import '../../blocs/historyidC/historyidC_screen_state.dart';

class HistoryidCScreen extends StatefulWidget {
  const HistoryidCScreen({super.key});

  @override
  State<HistoryidCScreen> createState() => _HistoryidCScreenState();
}

class _HistoryidCScreenState extends State<HistoryidCScreen>
    with TickerProviderStateMixin {
  late HistoryidCScreenBloc _bloc;
  late TabController _tabHistoryController;
  late TextEditingController _feedbackController;
  List<TaskModel> userHistory = [];

  @override
  void initState() {
    userHistory = [];
    _bloc = BlocProvider.of(context);
    _bloc.add(HistoryidCScreenTabPressEvent(1));
    _bloc.add(HistotyiDCScreenStartEvent());
    _tabHistoryController = TabController(
      length: 2,
      initialIndex: 1,
      vsync: this,
    );
    _tabHistoryController.addListener(() {
      if (_tabHistoryController.index != _tabHistoryController.previousIndex) {
        _bloc.add(HistoryidCScreenTabPressEvent(_tabHistoryController.index));
      }
    });
    _feedbackController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    _tabHistoryController.dispose();
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _bloc = BlocProvider.of<HistoryidCScreenBloc>(context);

    return BlocConsumer<HistoryidCScreenBloc, HistoryidCScreenState>(
      builder: _builder,
      listener: _listener,
    );
  }

  void _listener(BuildContext context, HistoryidCScreenState state) {
    if (state is BookingDeleteidCErrorState) {
      context.showSnackBar("Hủy thành công!");
    }
    if (state is BookingDeleteErrorState) {
      context.showSnackBar("Hủy thắt bại!");
    }
    if (state is HistoryScreenInitialState) {
      setState(() {});
    }
  }

  Widget _builder(BuildContext context, HistoryidCScreenState state) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: "history_screen",
        backgroundColor: ColorUtil.brightYellow,
        shape: const CircleBorder(
          side: BorderSide(color: Colors.white, width: 3.0),
        ),
        tooltip: "Thêm công việc",
        onPressed: () {
          var phone = '';
          if (_bloc.args.containsKey('phone')) {
            phone = _bloc.args['phone'];
          }
          Navigator.pushNamed(
            context,
            App.instance.userApp?.isUserCustomer() == true
                ? Routes.serviceScreen
                : App.instance.userApp?.isUserRole() == true
                ? Routes.staffServiceScreen
                : Routes.staffServiceScreenSale,
            arguments: {"listService": [], "index": "", "phone": phone},
          );
        },
        child: const Icon(Icons.add),
      ),
      appBar: MyAppBar(title: "Lịch sử", isBackNavigation: true),
      body: LoadingIndicator(
        // isLoading: _bloc.isLoading,
        isLoading: state is HistoryidCScreenInitialState && _bloc.isLoading,
        child: RefreshIndicator(
          onRefresh: () async {
            _bloc.add(
              HistoryidCScreenTabPressEvent(_tabHistoryController.index),
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
    var dataFormat = _formatDatetime(taskModel.timeStar ?? "");
    return Column(
      children: [
        ButtonWidget(
          onTap: () {
            _detailTask(taskModel);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: paddingHorizontal,
              vertical: 8,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.only(
                            bottom: 1, // space between underline and text
                          ),
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color:
                                    ColorUtil.raisinBlack, // Text colour here
                                width: 1.0, // Underline width
                              ),
                            ),
                          ),
                          child: Text(
                            'Mã dịch vụ: DV_${taskModel.id}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: ColorUtil.raisinBlack,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (taskModel.status == '1' ||
                        taskModel.status == '2' ||
                        taskModel.status == '5')
                      Align(
                        alignment: Alignment.centerRight,
                        child: _buildButton(
                          text: 'Hủy',
                          isPositive: false,
                          action: () {
                            _cancelTask(taskModel);
                          },
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
              ],
            ),
          ),
        ),
        ButtonWidget(
          onTap: () async {
            _detailTask(taskModel);
          },
          child: Padding(
            padding: const EdgeInsets.only(
              left: 20,
              top: 0,
              bottom: 10,
              right: 8,
            ),
            child: Table(
              columnWidths: const {1: FlexColumnWidth(1)},
              children: [
                TableRow(
                  children: [
                    Container(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: const Text(
                        "Trạng thái dịch vụ: ",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(taskModel.getStatus()),
                  ],
                ),
                TableRow(
                  children: [
                    Container(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: const Text(
                        'Dịch vụ: ',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      taskModel.name ?? '',
                      style: const TextStyle(fontSize: 15),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Container(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: const Text(
                        'Thời gian:',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      dataFormat,
                      style: const TextStyle(
                        fontSize: 15,
                        color: ColorUtil.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Container(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: const Text(
                        'Kỹ thuật viên:',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      taskModel.staff?.username ?? "",
                      style: const TextStyle(fontSize: 15),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Container(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: const Text(
                        'Số điện thoại KTV:',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    GestureDetector(
                      child: Text(
                        taskModel.staff?.phone ?? "",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onTap: () async {
                        const url = "tel:0963456911";
                        await launchUrl(Uri.parse(url));
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItemMachineInUse(BuildContext context, int index) {
    OrderModel machine = _bloc.lstMachine[index];
    var dataFormat = _formatDatetime(machine.createdAt);
    return ButtonWidget(
      onTap: () {
        print(_bloc.args['phone']);
        _detailMachine(machine, _bloc.args['phone']);
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

  Widget _buildButton({text, isPositive, action}) {
    return isPositive
        ? ButtonWidget(
            color: isPositive ? ColorUtil.bangladeshGreen : Colors.grey,
            borderRadius: BorderRadius.circular(30),
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
          )
        : ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all<Color>(ColorUtil.white),
              shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(
                    color: ColorUtil.bangladeshGreen,
                    width: 1,
                  ),
                ),
              ),
            ),
            child: Text(
              text,
              style: const TextStyle(color: ColorUtil.bangladeshGreen),
            ),
            onPressed: () {
              if (action == null) {
                Navigator.pop(context);
              } else {
                action();
              }
            },
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
                      BookingDeleteidCTaskEvent(
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

  void _detailMachine(OrderModel orderModel, String userId) async {
    Navigator.pushNamed(
      context,
      Routes.machineDetail,
      arguments: {'id_oder': orderModel, 'id_user': userId},
    );
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
