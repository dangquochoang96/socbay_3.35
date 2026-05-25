import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socbay/blocs/task/task_screen_event.dart';
import 'package:socbay/blocs/task/task_screen_sale_bloc.dart';
import 'package:socbay/blocs/task/task_screen_state.dart';
import 'package:socbay/blocs/booking/detail_booking/detail_booking_bloc.dart';
import 'package:socbay/blocs/booking/detail_booking/detail_booking_event.dart';
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

class TaskAvailableTabSale extends StatefulWidget {
  const TaskAvailableTabSale({super.key});

  @override
  State<TaskAvailableTabSale> createState() => _TaskAvailableTabState();
}

class _TaskAvailableTabState extends State<TaskAvailableTabSale> {
  late TaskScreenSaleBloc _bloc;
  late DetailBookingBloc _blocDetail;
  late ScrollController _scrollController;
  late TextEditingController _feedbackController;
  late TextEditingController _searchController;
  int _page = 0;
  String _searchQuery = '';
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  @override
  void initState() {
    _bloc = BlocProvider.of(context);
    _bloc.add(StaffTaskScreenGetTaskAssigedEvent(page: _page));
    _blocDetail = BlocProvider.of<DetailBookingBloc>(context);
    _scrollController = ScrollController();
    _feedbackController = TextEditingController();
    _searchController = TextEditingController();
    _scrollController.addListener(() {
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
      });
    } else {
      setState(() {
      });
    }

    if (selectedTime != null) {
      setState(() {
      });
    } else {
      setState(() {
        // _timeStart = TimeOfDay.now().toTimeString();
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _feedbackController.dispose();
    _searchController.dispose();
    _page = 0;
    _bloc.listTaskModel.clear();
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TaskScreenSaleBloc, TaskScreenState>(
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
      context.showSnackBar("Hủy thắt bại!");
    }
    if (state is MyTaskScreenInitialState) {
      setState(() {});
    }
  }

  List<TaskModel> get _filteredTasks {
    if (_searchQuery.isEmpty) {
      return _bloc
          .staffListTaskAssigedModel; // Return all tasks if search query is empty
    } else {
      // Filter tasks based on service ID containing the search query
      return _bloc.staffListTaskAssigedModel.where((task) {
        return (task.customer?.phone != null &&
                task.customer!.phone!
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ||
            task.customer?.username != null &&
                task.customer!.username!
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ||
            task.customer?.address != null &&
                task.customer!.address!
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()));
      }).toList();
    }
  }

  Widget _builder(BuildContext context, state) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: "Tìm Kiếm",
                    hintText: "Tìm Kiếm",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25.0)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 5), // Add some spacing
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _searchQuery = _searchController.text;
                  });
                },
                child: const Text('Search'),
              ),
              const SizedBox(width: 5), // Add some spacing
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  setState(() {
                    _searchQuery = '';
                    _searchController.clear();
                  });
                },
                child: const Text('All'),
              ),
            ],
          ),
        ),
        Expanded(
          child: LoadingIndicator(
            isLoading: _bloc.isLoading,
            child: RefreshIndicator(
              onRefresh: () async {
                _bloc.add(const StaffTaskScreenGetTaskAssigedEvent(
                    isRefresh: true, page: 0));
              },
              child: _bloc.staffListTaskAssigedModel.isEmpty && !_bloc.isLoading
                  ? const Center(child: Text("Chưa có công việc"))
                  : ListView.separated(
                      controller: _scrollController,
                      itemBuilder: _itemBuilder,
                      itemCount: _filteredTasks.length,
                      padding: const EdgeInsets.symmetric(
                          horizontal: paddingHorizontal,
                          vertical: paddingVertical),
                      separatorBuilder: (BuildContext context, int index) {
                        return const Divider(
                          thickness: 1,
                          color: ColorUtil.bangladeshGreen,
                        );
                      },
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _itemBuilder(BuildContext context, int index) {
    if (index >= _filteredTasks.length) {
      return const IndicatorLoadMore();
    }
    TaskModel taskModel = _filteredTasks[index];
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
                    _buildButton(
                      text: 'Hủy',
                      isPositive: false,
                      action: () {
                        _cancelTask(taskModel);
                      },
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
          style: TextStyle(color: isHighlight ? Colors.red : Colors.black),
        ),
      ],
    );
  }

  void _detailTask(TaskModel taskModel) {
    Navigator.pushNamed(context, Routes.detailBookingScreen,
        arguments: {'id': taskModel.id});
  }

  void _editBooking(TaskModel taskModel) {
    Navigator.pushNamed(context, Routes.editServiceScreen,
        arguments: {'id': taskModel.id}).then((value) async {
      if (value == null) {
        return;
      } else {
        Map<String, dynamic>? result = value as Map<String, dynamic>?;
        if (result != null) {
          setState(() {
            _blocDetail.add(DetailBookingStartedEvent());
            _bloc.add(const StaffTaskScreenGetTaskAssigedEvent(isRefresh: true));
            _bloc.add(const StaffTaskScreenGetTaskByDayEvent(isRefresh: true));
          });
        }
      }
    });
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
            ))
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
                      }),
                  const SizedBox(width: 16),
                  _buildButtonDialog(
                      isPositive: true,
                      text: 'Gửi',
                      action: () {
                        _bloc.add(BookingDeleteTaskEvent(taskModel.id ?? 0,
                            taskModel.name!, _feedbackController.text));
                        Navigator.pop(context);
                        _feedbackController.clear();
                      }),
                ],
              )
            ],
          );
        });
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

}
