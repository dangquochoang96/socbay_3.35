import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socbay/blocs/task/task_screen_bloc.dart';
import 'package:socbay/blocs/task/task_screen_event.dart';
import 'package:socbay/blocs/task/task_screen_state.dart';
import 'package:socbay/constants/constants.dart';
import 'package:socbay/data/model/task_model.dart';
import 'package:socbay/routes.dart';
import 'package:socbay/screens/staff/technique/technique_screen.dart';
import 'package:socbay/utils/color_util.dart';
import 'package:socbay/utils/context_extension.dart';
import 'package:socbay/utils/scroll_util.dart';
import 'package:socbay/widgets/button_widget.dart';
import 'package:socbay/widgets/indicator_loadmore.dart';
import 'package:socbay/widgets/loading_indicator.dart';

import '../../../data/model/user_model.dart';

class TaskWaitTab extends StatefulWidget {
  const TaskWaitTab({super.key});

  @override
  State<TaskWaitTab> createState() => _TaskWaitState();
}

class _TaskWaitState extends State<TaskWaitTab> {
  late TaskScreenBloc _bloc;
  late ScrollController _scrollController;
  late TextEditingController _feedbackController;
  int _page = 0;
  UserModel? _favouriteStaff;

  @override
  void initState() {
    super.initState();
    _bloc = BlocProvider.of(context);
    _bloc.add(StaffTaskScreenGetTaskAssigedEvent(page: _page));
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
          _page++;
          _bloc.add(StaffTaskScreenGetTaskAssigedEvent(page: _page));
        },
      );
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _feedbackController.dispose();
    _page = 0;
    _bloc.listTaskModel.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TaskScreenBloc, TaskScreenState>(
      builder: _builder,
      listener: _listener,
    );
  }

  void _listener(BuildContext context, state) {
    if (state is BookingDeleteSuccessState) {
      context.showSnackBar("Hủy thành công!");
      _bloc.add(
        const StaffTaskScreenGetTaskAssigedEvent(isRefresh: true, page: 0),
      );
    }
    if (state is BookingDeleteErrorState) {
      context.showSnackBar("Hủy thắt bại!");
    }
  }

  List<TaskModel> taskList = [
    TaskModel(
      id: 1,
      name: "Dịch vụ 1",
      des: "Mô tả dịch vụ 1",
      timeStart: "08:00 AM",
    ),
    TaskModel(
      id: 2,
      name: "Dịch vụ 2",
      des: "Mô tả dịch vụ 2",
      timeStart: "10:00 AM",
    ),
  ];
  Widget _builder(BuildContext context, state) {
    return LoadingIndicator(
      isLoading: _bloc.isLoading,
      child: RefreshIndicator(
        onRefresh: () async {
          _bloc.add(
            const StaffTaskScreenGetTaskAssigedEvent(isRefresh: true, page: 0),
          );
        },
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          controller: _scrollController,
          itemBuilder: _itemBuilder,
          itemCount: taskList.length,
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
    if (index >= taskList.length) {
      return const IndicatorLoadMore();
    }
    TaskModel taskModel = taskList[index];

    bool isProcessing = false;

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
            ],
          ),
        ),
        Table(
          children: [
            _buildTableRow(
              title: 'Trạng thái dịch vụ:',
              content: taskModel.getStatus(),
              isHighlight: false,
            ),
            _buildTableRow(
              title: 'Dịch vụ:',
              content: taskModel.name ?? "Không có tên",
              isHighlight: false,
            ),
            _buildTableRow(
              title: 'Nội dung:',
              content: taskModel.des ?? "Không có nội dung",
              isHighlight: false,
            ),
            _buildTableRow(
              title: 'Thời gian:',
              content: taskModel.timeStart,
              isHighlight: false,
            ),
          ],
        ),
        Align(
          alignment: Alignment.center,
          child: ElevatedButton(
            onPressed: () {
              if (!isProcessing) {
                _showInputDialog(context, () {
                  setState(() {
                    isProcessing = true;
                  });
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF006A4E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            child: const Text("Giao việc"),
          ),
        ),
      ],
    );
  }

  void _showInputDialog(BuildContext context, Function() onConfirm) {
    TextEditingController usernameController = TextEditingController(
      text: _favouriteStaff?.username,
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("KTV tiếp nhận"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _buildField(
                '',
                'Chọn KTV',
                Icons.person_outlined,
                null,
                value: _favouriteStaff?.username ?? "",
                onTap: () async {
                  UserModel? selectedStaff = await _onChooseFavouriteStaff();
                  if (selectedStaff != null) {
                    usernameController.text = selectedStaff.username!;
                    setState(() {
                      _favouriteStaff = selectedStaff;
                    });
                  }
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Hủy"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Xác nhận"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildField(
    String titleTextField,
    String hint,
    IconData iconPrefix,
    IconData? iconSuffix, {
    required String value,
    required void Function() onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Visibility(
          visible: titleTextField == '' ? false : true,
          child: Text(
            titleTextField,
            style: const TextStyle(color: ColorUtil.raisinBlack, fontSize: 15),
          ),
        ),
        const SizedBox(height: 5),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: ColorUtil.bangladeshGreen, width: 0.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Icon(iconPrefix, color: ColorUtil.spanishGray),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    value.isEmpty ? hint : value,
                    style: TextStyle(
                      color: value.isEmpty
                          ? ColorUtil.silverChalice
                          : ColorUtil.raisinBlack,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Icon(iconSuffix, color: ColorUtil.spanishGray),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Future<UserModel?> _onChooseFavouriteStaff() async {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => TechniqueScreen(
              initialTabIndex: 1,
              favoriteStaff: _favouriteStaff,
            ),
          ),
        )
        .then((value) {
          Map<String, dynamic>? result = {};
          result = value as Map<String, dynamic>?;
          if (result != null) {
            setState(() {
              _favouriteStaff = result!['favouriteStaff'];
            });
          }
        });
    return null;
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
            color: ColorUtil.raisinBlack,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          "$content",
          style: TextStyle(
            color: isHighlight ? ColorUtil.bangladeshGreen : Colors.black,
          ),
        ),
      ],
    );
  }

  void _detailTask(TaskModel taskModel) {
    Navigator.pushNamed(
      context,
      Routes.detailBookingScreen,
      arguments: {'id': taskModel.id},
    );
  }
}
