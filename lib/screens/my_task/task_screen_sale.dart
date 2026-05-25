import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socbay/blocs/task/task_screen_sale_bloc.dart';
import 'package:socbay/blocs/task/task_screen_state.dart';
import 'package:socbay/screens/my_task/my_task_sale/my_task_sale.dart';
import 'package:socbay/screens/my_task/rent_task/rent_task.dart';
import 'package:socbay/screens/my_task/rent_task_available/rent_task_available.dart';
import 'package:socbay/screens/my_task/task_available/task_available_tab_sale.dart';
import 'package:socbay/utils/color_util.dart';
import 'package:socbay/widgets/my_app_bar.dart';


class TaskScreenSale extends StatefulWidget {
  const TaskScreenSale({super.key});

  @override
  State<TaskScreenSale> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreenSale> with TickerProviderStateMixin {
  late TabController _tabController;
  int index = 0;
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TaskScreenSaleBloc, TaskScreenState>(
        builder: _builder, listener: _listener);
  }

  @override
  void initState() {
    super.initState();
    // _bloc = BlocProvider.of(context);
    _tabController = TabController(
      length: 4,
      initialIndex: 0,
      vsync: this,
    );
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          index = _tabController.index;
        });
      }
    });
  }

  void _listener(BuildContext context, state) {}

  Widget _builder(BuildContext context, TaskScreenState state) {
    return Scaffold(
        appBar: MyAppBar(
          title: "Công việc đã tạo",
          // titleFontSize: 22,
          isBackNavigation: false,
        ),
        body:Column(
          children: [
            TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: ColorUtil.bangladeshGreen,
              tabs: [
                _buildTab('Trong ngày'),
                _buildTab('Tồn đọng'),
                _buildTab('Thuê'),
                _buildTab('Tồn đọng thuê'),
              ],
            ),
            Expanded(
              child: IndexedStack(
                index: _tabController.index,
                children: [
                  _buildMyTask(),
                  _buildTaskAvailable(),
                  _buildMyTaskRent(),
                  _buildTaskAvailableRent(),
                ],
              ),
            )
          ],
        )


    );
  }

  Tab _buildTab(text) {
    return Tab(
      height: 36,
      child: Text(
        text,
        style: const TextStyle(color: ColorUtil.bangladeshGreen, fontSize: 16),
      ),
    );
  }

  Widget _buildMyTask() {
    return const MyTaskTabSale();
  }

  Widget _buildTaskAvailable() {
    return const TaskAvailableTabSale();
  }

  Widget _buildMyTaskRent() {
    return const RentTaskTabSale();
  }

  Widget _buildTaskAvailableRent() {
    return const RentTaskAvailableTabSale();
  }
}
