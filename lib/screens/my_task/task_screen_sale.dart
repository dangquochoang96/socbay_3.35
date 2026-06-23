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

class _TaskScreenState extends State<TaskScreenSale>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int index = 0;
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TaskScreenSaleBloc, TaskScreenState>(
      builder: _builder,
      listener: _listener,
    );
  }

  @override
  void initState() {
    super.initState();
    // _bloc = BlocProvider.of(context);
    _tabController = TabController(length: 4, initialIndex: 0, vsync: this);
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
      body: Column(
        children: [
          Container(
            height: 46,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: ColorUtil.bangladeshGreen,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: ColorUtil.bangladeshGreen.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              labelColor: Colors.white,
              unselectedLabelColor: ColorUtil.graniteGray,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
              indicatorWeight: 0,
              indicatorPadding: EdgeInsets.zero,
              labelPadding: const EdgeInsets.symmetric(horizontal: 16),
              tabs: [
                _buildTab('Trong ngày', Icons.today_rounded),
                _buildTab('Tồn đọng', Icons.pending_actions_rounded),
                _buildTab('Thuê', Icons.handshake_rounded),
                _buildTab('Tồn đọng thuê', Icons.history_toggle_off_rounded),
              ],
            ),
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
          ),
        ],
      ),
    );
  }

  Tab _buildTab(String text, IconData icon) {
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon, size: 16), const SizedBox(width: 6), Text(text)],
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
