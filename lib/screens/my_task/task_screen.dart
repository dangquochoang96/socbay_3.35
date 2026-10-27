import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socbay/blocs/task/task_screen_bloc.dart';
import 'package:socbay/blocs/task/task_screen_state.dart';
import 'package:socbay/screens/my_task/contacted_task/contacted_task.dart';
import 'package:socbay/screens/my_task/my_task/my_task_tab.dart';
import 'package:socbay/screens/my_task/rent_task/rent_task_ktv.dart';
import 'package:socbay/utils/color_util.dart';
import 'package:socbay/widgets/my_app_bar.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  int _orderTypeIndex = 0; // 0: Đã liên hệ, 1: Đơn dịch vụ, 2: Đơn thuê

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
          // Phân loại: Đã liên hệ vs Đơn dịch vụ vs Đơn thuê
          _buildOrderTypeSelector(),

          const SizedBox(height: 10),

          // Danh sách công việc tương ứng
          Expanded(
            child: IndexedStack(
              index: _orderTypeIndex,
              children: const [
                ContactedTaskTab(), // Đã liên hệ (api contactedTasks)
                MyTaskTab(), // Đơn dịch vụ (api allTasks)
                RentTaskTab(), // Đơn thuê (api allRentTasks)
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
            title: 'Đã liên hệ',
            icon: Icons.phone_callback_rounded,
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
            title: 'Đơn dịch vụ',
            icon: Icons.home_repair_service_rounded,
            isSelected: _orderTypeIndex == 1,
            onTap: () {
              if (_orderTypeIndex != 1) {
                setState(() {
                  _orderTypeIndex = 1;
                });
              }
            },
          ),
          _buildOrderTypeItem(
            title: 'Đơn thuê',
            icon: Icons.handshake_rounded,
            isSelected: _orderTypeIndex == 2,
            onTap: () {
              if (_orderTypeIndex != 2) {
                setState(() {
                  _orderTypeIndex = 2;
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
                size: 15,
                color: isSelected ? Colors.white : ColorUtil.graniteGray,
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected ? Colors.white : ColorUtil.graniteGray,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
