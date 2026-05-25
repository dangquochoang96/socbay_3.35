import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:socbay/blocs/rent-task/rent_task_screen_ktv_bloc.dart';
import 'package:socbay/blocs/rent-task/rent_task_screen_event.dart';
import 'package:socbay/blocs/rent-task/rent_task_screen_state.dart';
import 'package:socbay/constants/constants.dart';
import 'package:socbay/data/model/task_model.dart';
import 'package:socbay/routes.dart';
import 'package:socbay/utils/color_util.dart';
import 'package:socbay/utils/context_extension.dart';
import 'package:socbay/utils/date_util.dart';
import 'package:socbay/utils/scroll_util.dart';
import 'package:socbay/widgets/button_widget.dart';
import 'package:socbay/widgets/indicator_loadmore.dart';
import 'package:socbay/widgets/loading_indicator.dart';
import 'package:socbay/widgets/text_field_default.dart';

class RentTaskAvailableTab extends StatefulWidget {
  const RentTaskAvailableTab({super.key});

  @override
  State<RentTaskAvailableTab> createState() => _RentTaskAvailableTabState();
}

class _RentTaskAvailableTabState extends State<RentTaskAvailableTab> {
  late RentTaskScreenKTVBloc _bloc;
  late ScrollController _scrollController;
  late TextEditingController _feedbackController;
  int _page = 0;
  String _dateStart = '';
  String _timeStart = '';

  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  @override
  void initState() {
    super.initState();
    _bloc = BlocProvider.of(context);
    _bloc.add(StaffTaskScreenGetTaskAssigedEvent(page: _page));
    _scrollController = ScrollController();
    _feedbackController = TextEditingController();
    _scrollController.addListener(() {
      if (_bloc.isClosed) _bloc = BlocProvider.of(context);
      scrollPaginationListener(
        scrollController: _scrollController,
        condition: (_scrollController.hasClients &&
                _scrollController.position.pixels ==
                    _scrollController.position.maxScrollExtent) ||
            _bloc.isLoading,
        paginationFunction: () {
          _page++;
          _bloc.add(StaffTaskScreenGetTaskAssigedEvent(page: _page));
        },
      );
    });
    if (selectedDate != null) {
      setState(() {
        _dateStart = selectedDate!.toDateString(format: 'dd/MM/yyyy');
      });
    } else {
      setState(() {
        _dateStart = DateTime.now().toDateString(format: 'dd/MM/yyyy');
      });
    }

    if (selectedTime != null) {
      setState(() {
        _timeStart = selectedTime!.toTimeString();
      });
    } else {
      setState(() {
        _timeStart = DateFormat('HH:mm').format(DateTime.now());
      });
    }
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RentTaskScreenKTVBloc, RentTaskScreenState>(
        builder: _builder, listener: _listener);
  }

  void _listener(BuildContext context, state) {
    if (state is BookingUpdateSuccessState) {
      context.showSnackBar("Cập nhật thành công!");
      _bloc.add(const StaffTaskScreenGetTaskByDayEvent(isRefresh: true));
    }
    if (state is BookingUpdateErrorState) {
      context.showSnackBar("Cập nhật thất bại!");
    }
    if (state is BookingDeleteSuccessState) {
      context.showSnackBar("Hủy thành công!");
    }
    if (state is BookingDeleteErrorState) {
      context.showSnackBar("Hủy thất bại!");
    }
    if (state is MyTaskScreenInitialState) {
      setState(() {});
    }
  }

  Widget _builder(BuildContext context, state) {
    return LoadingIndicator(
        isLoading: _bloc.isLoading,
        child: RefreshIndicator(
          onRefresh: () async {
            print("LOADINGGGG");
            _bloc.add(const StaffTaskScreenGetTaskAssigedEvent(
                isRefresh: true, page: 0));
          },
          child: _bloc.staffListTaskAssigedModel.isEmpty && !_bloc.isLoading
              ? const Center(child: Text("Chưa có công việc"))
              : ListView.separated(
                  controller: _scrollController,
                  itemBuilder: _itemBuilder,
                  itemCount: _bloc.staffListTaskAssigedModel.length,
                  padding: const EdgeInsets.symmetric(
                    horizontal: paddingHorizontal,
                    vertical: paddingVertical,
                  ),
                  separatorBuilder: (BuildContext context, int index) {
                    return const Divider(
                        thickness: 1, color: ColorUtil.bangladeshGreen);
                  },
                ),
        ));
  }

  Widget _itemBuilder(BuildContext context, int index) {
    if (index >= _bloc.staffListTaskAssigedModel.length) {
      return const IndicatorLoadMore();
    }
    TaskModel taskModel = _bloc.staffListTaskAssigedModel[index];
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
              if (taskModel.status == '1' ||
                  taskModel.status == '2' ||
                  taskModel.status == '5')
                Align(
                    alignment: Alignment.centerRight,
                    child: _buildButton(
                        text: 'Cập nhật',
                        isPositive: false,
                        action: () {
                          _updateTask(taskModel);
                        })),
            ],
          ),
        ),
        Table(
          children: [
            _buildTableRow(
                title: 'Thời gian:',
                content: taskModel.timeStar,
                isHighlight: true),
            _buildTableRow(
              title: 'Khách hàng:',
              content: taskModel.customer?.username,
              isHighlight: false,
            ),
            _buildTableRow(
              title: 'SĐT Khách:',
              content: taskModel.customer?.phone,
              isHighlight: false,
            ),
            _buildTableRow(
              title: 'Địa chỉ khách:',
              content: taskModel.customer?.address,
              isHighlight: false,
            ),
            _buildTableRow(
                title: 'Trạng thái dịch vụ:',
                content: taskModel.getStatus(),
                isHighlight: false),
            _buildTableRow(
                title: 'Công việc:',
                content: taskModel.name ?? "",
                isHighlight: false),
            _buildTableRow(
                title: 'Nội dung:',
                content: taskModel.des ?? "",
                isHighlight: false),
            _buildTableRow(
                title: 'Thông báo:',
                content: taskModel.noti ?? '',
                isHighlight: false),
          ],
        )
      ],
    );
  }

  TableRow _buildTableRow({
    required String title,
    required String? content,
    required bool isHighlight,
  }) {
    return TableRow(
      children: [
        Text(
          title,
          style: const TextStyle(
              color: ColorUtil.raisinBlack, fontWeight: FontWeight.bold),
        ),
        Text(
          "$content",
          style: TextStyle(
              color: isHighlight ? ColorUtil.bangladeshGreen : Colors.black),
        ),
      ],
    );
  }

  void _detailTask(TaskModel taskModel) {
    Navigator.pushNamed(context, Routes.detailRentBookingScreen,
        arguments: {'id': taskModel.id});
  }

  Widget _buildButton({text, isPositive, action}) {
    return isPositive
        ? ButtonWidget(
            color: isPositive ? ColorUtil.bangladeshGreen : Colors.grey,
            borderRadius: BorderRadius.circular(20), // Decreased border radius
            onTap: () {
              if (action == null) {
                Navigator.pop(context);
              } else {
                action();
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6), // Adjust padding
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 8, color: Colors.white), // Decreased font size
              ),
            ),
          )
        : ElevatedButton(
            style: ButtonStyle(
              backgroundColor:
                  WidgetStateProperty.all<Color>(ColorUtil.white),
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
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 2), // Adjust padding
              child: Text(
                text,
                style: const TextStyle(
                    fontSize: 9,
                    color: ColorUtil.bangladeshGreen), // Decreased font size
              ),
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

  Future<void> _updateTask(TaskModel taskModel) async {
    int? selectedOption = 5;
    DateTime tempDateTime =
        DateTime.parse(taskModel.timeStar ?? DateTime.now().toString());

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text(
                'Lý do hẹn lại',
                textAlign: TextAlign.center,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildFormDoubleHorizontal(
                    'Hẹn lại giờ',
                    Icons.calendar_today,
                    Icons.av_timer_sharp,
                    firstValue: _dateStart,
                    secondValue: _timeStart,
                    onTapFirst: () async {
                      final DateTime? picked = await showDatePicker(
                          context: context,
                          locale: const Locale("vi", "VN"),
                          initialDate: selectedDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)));
                      if (picked != null && picked != selectedDate) {
                        selectedDate = picked;
                        setState(() {
                          _dateStart =
                              selectedDate!.toDateString(format: "dd/MM/yyyy");
                          tempDateTime = DateTime(
                            picked.year,
                            picked.month,
                            picked.day,
                            tempDateTime.hour,
                            tempDateTime.minute,
                          );
                        });
                      }
                    },
                    onTapSecond: () async {
                      final TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: selectedTime ?? TimeOfDay.now(),
                      );
                      if (picked != null && picked != selectedTime) {
                        selectedTime = picked;
                        setState(() {
                          final hour = picked.hour.toString().padLeft(2, "0");
                          final minute =
                              picked.minute.toString().padLeft(2, "0");
                          _timeStart = "$hour:$minute";
                          tempDateTime = DateTime(
                            tempDateTime.year,
                            tempDateTime.month,
                            tempDateTime.day,
                            picked.hour,
                            picked.minute,
                          );
                          print("X6");
                          print(tempDateTime);
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFieldDefault(
                    controller: _feedbackController,
                    maxLines: 3,
                    hintText: 'Lý do',
                  ),
                  const SizedBox(height: 16),
                  Column(
                    // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        children: [
                          Radio<int>(
                            value: 5,
                            groupValue: selectedOption,
                            onChanged: (int? value) {
                              setState(() {
                                selectedOption = value;
                              });
                            },
                          ),
                          const Text(
                            'Nhận Đơn',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Radio<int>(
                            value: 1,
                            groupValue: selectedOption,
                            onChanged: (int? value) {
                              setState(() {
                                selectedOption = value;
                              });
                            },
                          ),
                          const Text(
                            'Không nhận Đơn',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Radio<int>(
                            value: 2,
                            groupValue: selectedOption,
                            onChanged: (int? value) {
                              setState(() {
                                selectedOption = value;
                              });
                            },
                          ),
                          const Text(
                            'Khách hàng hủy',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildButtonDialog(
                      isPositive: false,
                      text: 'Cancel',
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
                        if (_bloc.isClosed) _bloc = BlocProvider.of(context);

                        if (selectedOption == 1 || selectedOption == 2) {
                          _bloc.add(StaffTaskScreenUpdateTaskDayDoneEvent(
                            taskModel.id ?? 0,
                            taskModel.name!,
                            _feedbackController.text,
                            taskModel.des ?? '',
                            selectedOption.toString(),
                            taskModel.priority ?? "1",
                            tempDateTime.toString(),
                          ));

                          _bloc.staffListTaskAssigedModel.removeWhere(
                              (element) => element.id == taskModel.id);

                          Navigator.pop(context);
                          _feedbackController.clear();
                        } else {
                          _bloc.add(StaffTaskScreenUpdateTaskDayDoneEvent(
                            taskModel.id ?? 0,
                            taskModel.name!,
                            _feedbackController.text,
                            taskModel.des ?? '',
                            selectedOption.toString(),
                            taskModel.priority ?? "1",
                            tempDateTime.toString(),
                          ));

                          Navigator.pop(context);
                          _feedbackController.clear();
                        }
                      },
                    ),
                  ],
                ),
              ],
            );
          },
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
        ));
  }

  Widget _buildFormDoubleHorizontal(
    String titleTextField,
    IconData iconPrefixFirst,
    IconData iconPrefixSecond, {
    required String firstValue,
    required String secondValue,
    required void Function() onTapFirst,
    required void Function() onTapSecond,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titleTextField,
          style: const TextStyle(color: ColorUtil.raisinBlack, fontSize: 15),
        ),
        const SizedBox(
          height: 5,
        ),
        Row(children: [
          Expanded(
              flex: 2,
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                        color: ColorUtil.bangladeshGreen, width: 0.5)),
                child: GestureDetector(
                    onTap: onTapFirst,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Icon(
                            iconPrefixFirst,
                            color: ColorUtil.spanishGray,
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Flexible(
                            child: Text(
                                firstValue.isEmpty ? 'dd/MM/yyyy' : firstValue,
                                style: TextStyle(
                                    color: firstValue.isEmpty
                                        ? ColorUtil.silverChalice
                                        : ColorUtil.raisinBlack)))
                      ],
                    )),
              )),
          const SizedBox(
            width: 5,
          ),
          Expanded(
            flex: 1,
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  border:
                      Border.all(color: ColorUtil.bangladeshGreen, width: 0.5)),
              child: GestureDetector(
                onTap: onTapSecond,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 2.0),
                      child: Icon(
                        iconPrefixSecond,
                        color: ColorUtil.spanishGray,
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Flexible(
                        child: Text(secondValue.isEmpty ? 'hh:mm' : secondValue,
                            style: TextStyle(
                                color: secondValue.isEmpty
                                    ? ColorUtil.silverChalice
                                    : ColorUtil.raisinBlack)))
                  ],
                ),
              ),
            ),
          )
        ])
      ],
    );
  }
}
