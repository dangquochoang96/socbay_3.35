import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socbay/blocs/booking/booking_bloc.dart';
import 'package:socbay/blocs/booking/booking_event.dart';
import 'package:socbay/blocs/booking/booking_state.dart';
import 'package:socbay/constants/constants.dart';
import 'package:socbay/data/model/task_model.dart';
import 'package:socbay/paths/images.dart';
import 'package:socbay/utils/color_util.dart';
import 'package:socbay/utils/image_util.dart';
import 'package:socbay/widgets/loading_indicator.dart';
import 'package:socbay/widgets/my_app_bar.dart';

import '../../routes.dart';
import '../../widgets/button_widget.dart';
import '../../widgets/text_field_default.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late BookingBloc _bloc;
  late TextEditingController _feedbackController;

  @override
  void initState() {
    _bloc = BlocProvider.of(context);
    _bloc.add(BookingStartedEvent());
    _feedbackController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BookingBloc, BookingState>(
      builder: _builder,
      listener: _listener,
    );
  }

  void _listener(BuildContext context, BookingState state) {}

  Widget _builder(BuildContext context, BookingState state) {
    return Scaffold(
      appBar: MyAppBar(title: "Đặt lịch", isBackNavigation: false),
      body: LoadingIndicator(
        isLoading: _bloc.isLoading,
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: paddingVertical),
            itemBuilder: _itemBuilder,
            separatorBuilder: _buildSeparator,
            itemCount: _bloc.listTaskModel.length,
          ),
        ),
      ),
    );
  }

  Future<void> _onRefresh() async {
    _bloc.add(BookingStartedEvent());
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

  void _detailTask(TaskModel taskModel) {
    Navigator.pushNamed(
      context,
      Routes.detailBookingScreen,
      arguments: {'id': taskModel.id},
    );
  }

  Widget _itemBuilder(BuildContext context, int index) {
    TaskModel taskModel = _bloc.listTaskModel[index];
    return GestureDetector(
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
                Expanded(
                  child: Text(
                    'Mã dịch vụ: ${taskModel.id}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: ColorUtil.raisinBlack,
                      fontSize: 16,
                    ),
                  ),
                ),
                Text(
                  taskModel.getStatus(),
                  style: const TextStyle(color: ColorUtil.bangladeshGreen),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Dịch vụ: ${taskModel.name ?? ''}',
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                ImageUtil.loadAssetsImage(
                  fileName: Images.iconMarker,
                  width: 15,
                  height: 15,
                ),
                const SizedBox(width: 5),
                // Flexible(
                //     child: Text(taskModel.address ?? 'Trống!',
                //         style: const TextStyle(
                //             color: ColorUtil.bangladeshGreen,
                //             overflow: TextOverflow.ellipsis),
                //         maxLines: 2))
              ],
            ),
            const SizedBox(height: 32),
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
      ),
    );
  }

  Widget _buildSeparator(BuildContext context, int index) {
    return const Divider(color: Colors.grey, height: 24);
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
