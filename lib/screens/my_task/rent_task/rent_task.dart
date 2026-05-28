import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socbay/blocs/rent-task/rent_task_screen_bloc.dart';
import 'package:socbay/blocs/rent-task/rent_task_screen_event.dart';
import 'package:socbay/blocs/rent-task/rent_task_screen_state.dart';
import 'package:socbay/constants/constants.dart';
import 'package:socbay/data/model/task_model.dart';
import 'package:socbay/routes.dart';
import 'package:socbay/utils/color_util.dart';
import 'package:socbay/utils/context_extension.dart';
import 'package:socbay/utils/scroll_util.dart';
import 'package:socbay/widgets/button_widget.dart';
import 'package:socbay/widgets/indicator_loadmore.dart';
import 'package:socbay/widgets/loading_indicator.dart';
import 'package:socbay/widgets/text_field_default.dart';

class RentTaskTabSale extends StatefulWidget {
  const RentTaskTabSale({super.key});

  @override
  State<RentTaskTabSale> createState() => _RentTaskTabSale();
}

class _RentTaskTabSale extends State<RentTaskTabSale> {
  late RentTaskScreenSaleBloc _bloc;
  late ScrollController _scrollController;

  late TextEditingController _feedbackController;
  var _isRefresh = true;

  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  @override
  void initState() {
    super.initState();
    _bloc = BlocProvider.of(context);
    _bloc.add(StaffTaskScreenGetTaskByDayEvent(isRefresh: _isRefresh));
    _isRefresh = false;
    _scrollController = ScrollController();
    _feedbackController = TextEditingController();
    _scrollController.addListener(() {
      scrollPaginationListener(
        scrollController: _scrollController,
        condition:
            (_scrollController.hasClients &&
                _scrollController.position.pixels ==
                    _scrollController.position.maxScrollExtent) ||
            _bloc.isLoading,
        paginationFunction: () {
          _bloc.add(StaffTaskScreenGetTaskByDayEvent(isRefresh: _isRefresh));
        },
      );
    });

    if (selectedDate != null) {
      setState(() {});
    } else {
      setState(() {});
    }

    if (selectedTime != null) {
      setState(() {});
    } else {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _feedbackController.dispose();
    _bloc.listTaskModel.clear();
    _bloc.close();
    _isRefresh = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RentTaskScreenSaleBloc, RentTaskScreenState>(
      builder: _builder,
      listener: _listener,
    );
  }

  void _listener(BuildContext context, state) {
    if (state is BookingDeleteSuccessState) {
      _bloc.add(const StaffTaskScreenGetTaskByDayEvent(isRefresh: true));
      _bloc.add(
        const StaffTaskScreenGetTaskAssigedEvent(isRefresh: true, page: 0),
      );
      _feedbackController.clear();
    }
    if (state is BookingDeleteErrorState) {
      context.showSnackBar("Hủy thất bại!");
    }
  }

  Widget _builder(BuildContext context, state) {
    return LoadingIndicator(
      isLoading: _bloc.isLoading,
      child: RefreshIndicator(
        onRefresh: () async {
          _isRefresh = true;
          _bloc.add(StaffTaskScreenGetTaskByDayEvent(isRefresh: _isRefresh));
        },
        child: _bloc.staffListTaskBydayModel.isEmpty && !_bloc.isLoading
            ? const CustomScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverFillRemaining(
                    child: Center(child: Text("Chưa có công việc")),
                  ),
                ],
              )
            : ListView.separated(
                //controller: _scrollController,
                itemBuilder: _itemBuilder,
                itemCount: _bloc.staffListTaskBydayModel.length,
                padding: const EdgeInsets.symmetric(
                  horizontal: paddingHorizontal,
                  vertical: paddingVertical,
                ),
                separatorBuilder: (BuildContext context, int index) {
                  return const Divider(
                    thickness: 1,
                    color: ColorUtil.bangladeshGreen,
                  );
                },
              ),
      ),
    );
  }

  Widget _itemBuilder(BuildContext context, int index) {
    if (index >= _bloc.staffListTaskBydayModel.length) {
      return const IndicatorLoadMore();
    }
    TaskModel taskModel = _bloc.staffListTaskBydayModel[index];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ButtonWidget(
          onTap: () {
            _detailTask(taskModel);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mã dịch vụ: ${taskModel.id}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: ColorUtil.bangladeshGreen,
                  fontSize: 16,
                ),
              ),
              // if ((taskModel.status == '1' || taskModel.status == '2' || taskModel.status == '5') && App.instance.userApp?.id.toString() == taskModel.userCreate)
              if ((taskModel.status == '1' ||
                  taskModel.status == '2' ||
                  taskModel.status == '5'))
                Row(
                  children: [
                    _buildButton(
                      text: 'Sửa',
                      isPositive: false,
                      action: () {
                        _editBooking(taskModel);
                      },
                    ),
                    const SizedBox(width: 8), // Adjust spacing if needed
                    Align(
                      alignment: Alignment.centerRight,
                      child: _buildButton(
                        text: 'Hủy',
                        isPositive: false,
                        action: () {
                          _cancelTask(taskModel);
                        },
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        Table(
          children: [
            _buildTableRow(
              title: 'Thời gian:',
              content: taskModel.timeStar,
              titleStyle: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
              isHighlight: true,
            ),
            _buildTableRow(
              title: 'Khách hàng:',
              content: taskModel.customer!.username,
              isHighlight: false,
            ),
            _buildTableRow(
              title: 'SĐT Khách:',
              content: taskModel.customer!.phone,
              isHighlight: false,
            ),
            _buildTableRow(
              title: 'Địa chỉ khách:',
              content: taskModel.customer!.address,
              isHighlight: false,
            ),
            _buildTableRow(
              title: 'Trạng thái dịch vụ:',
              content: taskModel.getStatus(),
              isHighlight: false,
            ),
            _buildTableRow(
              title: 'Công việc:',
              content: taskModel.name,
              isHighlight: false,
            ),
            _buildTableRow(
              title: 'Nội dung:',
              content: taskModel.des ?? '',
              isHighlight: false,
            ),
            _buildTableRow(
              title: 'Thông báo:',
              content: taskModel.noti ?? '',
              isHighlight: false,
            ),
          ],
        ),
      ],
    );
  }

  TableRow _buildTableRow({
    required String title,
    required String? content,
    required bool isHighlight,
    TextStyle? titleStyle,
  }) {
    return TableRow(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: ColorUtil.raisinBlack,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          "$content",
          style: TextStyle(color: isHighlight ? Colors.red : Colors.black),
        ),
      ],
    );
  }

  void _detailTask(TaskModel taskModel) {
    Navigator.pushNamed(
      context,
      Routes.detailRentBookingScreen,
      arguments: {'id': taskModel.id},
    );
  }

  Widget _buildButton({text, isPositive, action}) {
    return isPositive
        ? ButtonWidget(
            color: isPositive ? ColorUtil.bangladeshGreen : Colors.grey,
            borderRadius: BorderRadius.circular(10),
            onTap: () {
              if (action == null) {
                Navigator.pop(context);
              } else {
                action();
              }
            },
            child: SizedBox(
              width: 100,
              height: 30,
              child: Center(
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 10, color: Colors.white),
                ),
              ),
            ),
          )
        : ElevatedButton(
            style: ElevatedButton.styleFrom(
              fixedSize: const Size(100, 30),
              backgroundColor: ColorUtil.white,
              side: const BorderSide(
                color: ColorUtil.bangladeshGreen,
                width: 1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              if (action == null) {
                Navigator.pop(context);
              } else {
                action();
              }
            },
            child: Text(
              text,
              style: const TextStyle(
                color: ColorUtil.bangladeshGreen,
                fontSize: 15,
              ),
            ),
          );
  }

  void _editBooking(TaskModel taskModel) {
    Navigator.pushNamed(
      context,
      Routes.editRentServiceScreen,
      arguments: {'id': taskModel.id},
    ).then((value) async {
      if (value == null) {
        return;
      } else {
        Map<String, dynamic>? result = value as Map<String, dynamic>?;
        if (result != null) {
          _bloc.add(const StaffTaskScreenGetTaskByDayEvent(isRefresh: true));
          _bloc.add(const StaffTaskScreenGetTaskAssigedEvent(isRefresh: true));
        }
      }
    });
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
                      BookingDeleteTaskEvent(
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
}
