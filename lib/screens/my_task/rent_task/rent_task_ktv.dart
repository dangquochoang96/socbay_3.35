import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:socbay/blocs/rent-task/rent_task_screen_event.dart';
import 'package:socbay/blocs/rent-task/rent_task_screen_ktv_bloc.dart';
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

class RentTaskTab extends StatefulWidget {
  const RentTaskTab({super.key});

  @override
  State<RentTaskTab> createState() => _RentTaskTabState();
}

class _RentTaskTabState extends State<RentTaskTab> {
  late RentTaskScreenKTVBloc _bloc;
  late ScrollController _scrollController;

  late TextEditingController _feedbackController;
  var _isRefresh = true;
  String _dateStart = '';
  String _timeStart = '';

  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  // int? selectedOption = 0 ;
  @override
  void initState() {
    super.initState();
    _bloc = BlocProvider.of(context);
    _bloc.add(StaffTaskScreenGetTaskByDayEvent(isRefresh: _isRefresh));
    _isRefresh = false;
    _scrollController = ScrollController();
    _feedbackController = TextEditingController();
    _scrollController.addListener(() {
      if (_bloc.isClosed) _bloc = BlocProvider.of(context);
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
        // _timeStart = TimeOfDay.now().toTimeString();
        _timeStart = DateFormat('HH:mm').format(DateTime.now());
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RentTaskScreenKTVBloc, RentTaskScreenState>(
      builder: _builder,
      listener: _listener,
    );
  }

  void _listener(BuildContext context, state) {
    if (state is BookingUpdateSuccessState) {
      context.showSnackBar("Cập nhật thành công!");
      _bloc.add(const StaffTaskScreenGetTaskByDayEvent(isRefresh: true));
      _bloc.add(
        const StaffTaskScreenGetTaskAssigedEvent(isRefresh: true, page: 0),
      );
    }
    if (state is BookingUpdateErrorState) {
      context.showSnackBar("Cập nhật thất bại!");
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
                  return const SizedBox(height: 12);
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
    return _buildTaskCard(taskModel);
  }

  Widget _buildTaskCard(TaskModel taskModel) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _detailTask(taskModel),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.confirmation_number_outlined,
                            size: 20,
                            color: ColorUtil.bangladeshGreen,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Mã DV: ${taskModel.id}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: ColorUtil.bangladeshGreen,
                                fontSize: 16,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusBadge(taskModel.getStatus()),
                  ],
                ),
                const Divider(
                  height: 24,
                  thickness: 1,
                  color: Color(0xFFEEEEEE),
                ),
                _buildInfoRow(
                  Icons.access_time,
                  'Thời gian:',
                  _formatTaskDatetime(taskModel.timeStart),
                  valueColor: Colors.red,
                  isBoldValue: true,
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.person_outline,
                  'Khách hàng:',
                  taskModel.customer?.username ?? '',
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.phone_outlined,
                  'SĐT:',
                  taskModel.customer?.phone ?? '',
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.location_on_outlined,
                  'Địa chỉ:',
                  taskModel.customer?.address ?? '',
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.work_outline,
                  'Công việc:',
                  taskModel.name ?? '',
                ),
                if (taskModel.des != null && taskModel.des!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.description_outlined,
                    'Nội dung:',
                    taskModel.des!,
                  ),
                ],
                if (taskModel.noti != null && taskModel.noti!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.notifications_none,
                    'Thông báo:',
                    taskModel.noti!,
                    valueColor: Colors.red,
                  ),
                ],
                if (taskModel.status == '1' ||
                    taskModel.status == '2' ||
                    taskModel.status == '5') ...[
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: _buildActionButton(
                      icon: Icons.edit_outlined,
                      text: 'Cập nhật',
                      color: ColorUtil.bangladeshGreen,
                      onTap: () => _updateTask(taskModel),
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

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: ColorUtil.bangladeshGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: const TextStyle(
          color: ColorUtil.bangladeshGreen,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
    bool isBoldValue = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        SizedBox(
          width: 85,
          child: Text(
            label,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: valueColor ?? Colors.black87,
              fontSize: 14,
              fontWeight: isBoldValue ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18, color: Colors.white),
      label: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 0,
        minimumSize: const Size(0, 36),
      ),
    );
  }

  String _formatTaskDatetime(String? dateTimeString) {
    try {
      if (dateTimeString == null || dateTimeString.isEmpty) return "";
      DateTime getDateTime = DateTime.parse(dateTimeString);
      return DateFormat('HH:mm:ss dd/MM/yyyy').format(getDateTime);
    } on Exception catch (ex) {
      print("format datetime error: $ex");
      return dateTimeString ?? "";
    }
  }

  void _detailTask(TaskModel taskModel) {
    Navigator.pushNamed(
      context,
      Routes.detailRentBookingScreen,
      arguments: {'id': taskModel.id},
    );
  }

  Future<void> _updateTask(TaskModel taskModel) async {
    int? selectedOption = 5;
    DateTime tempDateTime = DateTime.parse(
      taskModel.timeStart ?? DateTime.now().toString(),
    );

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Lý do hẹn lại', textAlign: TextAlign.center),
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
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null && picked != selectedDate) {
                        selectedDate = picked;
                        setState(() {
                          _dateStart = selectedDate!.toDateString(
                            format: "dd/MM/yyyy",
                          );
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
                          final minute = picked.minute.toString().padLeft(
                            2,
                            "0",
                          );
                          _timeStart = "$hour:$minute";
                          tempDateTime = DateTime(
                            tempDateTime.year,
                            tempDateTime.month,
                            tempDateTime.day,
                            picked.hour,
                            picked.minute,
                          );
                          print("X1");
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
                                print("X1");
                                print(value);
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
                                print("X2");
                                print(value);
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
                                print("X3");
                                print(value);
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
                          _bloc.add(
                            StaffTaskScreenUpdateTaskDoneEvent(
                              taskModel.id ?? 0,
                              taskModel.name!,
                              _feedbackController.text,
                              taskModel.des ?? '',
                              selectedOption.toString(),
                              taskModel.priority ?? "1",
                              tempDateTime.toString(),
                            ),
                          );

                          _bloc.staffListTaskBydayModel.removeWhere(
                            (element) => element.id == taskModel.id,
                          );

                          Navigator.pop(context);
                          _feedbackController.clear();
                        } else {
                          _bloc.add(
                            StaffTaskScreenUpdateTaskDoneEvent(
                              taskModel.id ?? 0,
                              taskModel.name!,
                              _feedbackController.text,
                              taskModel.des ?? '',
                              selectedOption.toString(),
                              taskModel.priority ?? "1",
                              tempDateTime.toString(),
                            ),
                          );

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
      ),
    );
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
        const SizedBox(height: 5),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(
                    color: ColorUtil.bangladeshGreen,
                    width: 0.5,
                  ),
                ),
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
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          firstValue.isEmpty ? 'dd/MM/yyyy' : firstValue,
                          style: TextStyle(
                            color: firstValue.isEmpty
                                ? ColorUtil.silverChalice
                                : ColorUtil.raisinBlack,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              flex: 1,
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(
                    color: ColorUtil.bangladeshGreen,
                    width: 0.5,
                  ),
                ),
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
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          secondValue.isEmpty ? 'hh:mm' : secondValue,
                          style: TextStyle(
                            color: secondValue.isEmpty
                                ? ColorUtil.silverChalice
                                : ColorUtil.raisinBlack,
                          ),
                        ),
                      ),
                    ],
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
