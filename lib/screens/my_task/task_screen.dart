import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socbay/blocs/task/task_screen_bloc.dart';
import 'package:socbay/blocs/task/task_screen_state.dart';
import 'package:socbay/screens/my_task/my_task/my_task_tab.dart';
import 'package:socbay/screens/my_task/rent_task/rent_task_ktv.dart';
import 'package:socbay/screens/my_task/rent_task_available/rent_task_available_ktv.dart';
import 'package:socbay/screens/my_task/task_available/task_available_tab.dart';
import 'package:socbay/utils/color_util.dart';
import 'package:socbay/widgets/my_app_bar.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  int _orderTypeIndex = 0; // 0: Đơn dịch vụ, 1: Đơn thuê
  int _timeFilterIndex = 0; // 0: Trong ngày, 1: Tồn đọng

  int get _currentIndex => _orderTypeIndex * 2 + _timeFilterIndex;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TaskScreenBloc, TaskScreenState>(
      builder: _builder,
      listener: _listener,
    );
  }

  void _listener(BuildContext context, state) {}

  Widget _builder(BuildContext context, TaskScreenState state) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: MyAppBar(title: "Công việc", isBackNavigation: false),
      body: Column(
        children: [
          const SizedBox(height: 10),
          // TẦNG 1: Phân loại nghiệp vụ (Đơn dịch vụ vs Đơn thuê)
          _buildOrderTypeSelector(),

          const SizedBox(height: 8),
          // TẦNG 2: Bộ lọc thời gian (Trong ngày vs Tồn đọng)
          _buildTimeFilterSelector(),

          const SizedBox(height: 8),
          // Danh sách công việc tương ứng
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: [
                _buildMyTask(), // 0: Đơn dịch vụ - Trong ngày
                _buildTaskAvailable(), // 1: Đơn dịch vụ - Tồn đọng
                _buildMyTaskRent(), // 2: Đơn thuê - Trong ngày
                _buildTaskAvailableRent(), // 3: Đơn thuê - Tồn đọng
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTypeSelector() {
    return Container(
      height: 46,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Row(
        children: [
          _buildOrderTypeItem(
            title: 'Đơn dịch vụ',
            icon: Icons.home_repair_service_rounded,
            isSelected: _orderTypeIndex == 0,
            onTap: () {
              if (_orderTypeIndex != 0) {
                setState(() {
                  _orderTypeIndex = 0;
                });
              }
            },
          ),
          _buildOrderTypeItem(
            title: 'Đơn thuê',
            icon: Icons.handshake_rounded,
            isSelected: _orderTypeIndex == 1,
            onTap: () {
              if (_orderTypeIndex != 1) {
                setState(() {
                  _orderTypeIndex = 1;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTypeItem({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? ColorUtil.bangladeshGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: ColorUtil.bangladeshGreen.withValues(alpha: 0.25),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 17,
                color: isSelected ? Colors.white : ColorUtil.graniteGray,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected ? Colors.white : ColorUtil.graniteGray,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeFilterSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildTimeFilterChip(
            title: 'Trong ngày',
            icon: Icons.today_rounded,
            isSelected: _timeFilterIndex == 0,
            onTap: () {
              if (_timeFilterIndex != 0) {
                setState(() {
                  _timeFilterIndex = 0;
                });
              }
            },
          ),
          const SizedBox(width: 10),
          _buildTimeFilterChip(
            title: 'Tồn đọng',
            icon: Icons.pending_actions_rounded,
            isSelected: _timeFilterIndex == 1,
            onTap: () {
              if (_timeFilterIndex != 1) {
                setState(() {
                  _timeFilterIndex = 1;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTimeFilterChip({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? ColorUtil.bangladeshGreen.withValues(alpha: 0.1)
                : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? ColorUtil.bangladeshGreen
                  : const Color(0xFFE5E7EB),
              width: isSelected ? 1.4 : 1.0,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 15,
                color: isSelected
                    ? ColorUtil.bangladeshGreen
                    : const Color(0xFF6B7280),
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? ColorUtil.bangladeshGreen
                      : const Color(0xFF4B5563),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMyTask() {
    return const MyTaskTab();
  }

  Widget _buildTaskAvailable() {
    return const TaskAvailableTab();
  }

  Widget _buildMyTaskRent() {
    return const RentTaskTab();
  }

  Widget _buildTaskAvailableRent() {
    return const RentTaskAvailableTab();
  }
}
