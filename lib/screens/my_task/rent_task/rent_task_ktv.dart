import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:socbay/blocs/rent-task/rent_task_screen_event.dart';
import 'package:socbay/blocs/rent-task/rent_task_screen_ktv_bloc.dart';
import 'package:socbay/blocs/rent-task/rent_task_screen_state.dart';
import 'package:socbay/constants/constants.dart';
import 'package:socbay/constants/maps.dart';
import 'package:socbay/data/model/task_model.dart';
import 'package:socbay/routes.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:socbay/utils/color_util.dart';
import 'package:socbay/utils/context_extension.dart';
import 'package:socbay/utils/date_util.dart';
import 'package:socbay/utils/scroll_util.dart';
import 'package:socbay/widgets/indicator_loadmore.dart';
import 'package:socbay/widgets/loading_indicator.dart';

class RentTaskTab extends StatefulWidget {
  const RentTaskTab({super.key});

  @override
  State<RentTaskTab> createState() => _RentTaskTabState();
}

class _RentTaskTabState extends State<RentTaskTab> {
  late RentTaskScreenKTVBloc _bloc;
  late ScrollController _scrollController;
  late TextEditingController _searchController;
  late TextEditingController _feedbackController;
  late TextEditingController _addressController;

  Timer? _debounceTimer;
  int _page = 0;
  bool _isToday = true;

  String _dateStart = '';
  String _timeStart = '';
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  @override
  void initState() {
    super.initState();
    _bloc = BlocProvider.of(context);
    _scrollController = ScrollController();
    _searchController = TextEditingController();
    _feedbackController = TextEditingController();
    _addressController = TextEditingController();

    _fetchTasks(isRefresh: true, resetPage: true);

    _scrollController.addListener(() {
      if (_bloc.isClosed) _bloc = BlocProvider.of(context);
      scrollPaginationListener(
        scrollController: _scrollController,
        condition:
            (_scrollController.hasClients &&
                _scrollController.position.pixels >=
                    _scrollController.position.maxScrollExtent - 80) &&
            !_bloc.isLoading &&
            _bloc.hasMoreAllRentTasks,
        paginationFunction: () {
          _page++;
          _fetchTasks(isRefresh: false, resetPage: false);
        },
      );
    });

    if (selectedDate != null) {
      _dateStart = selectedDate!.toDateString(format: 'dd/MM/yyyy');
    } else {
      _dateStart = DateTime.now().toDateString(format: 'dd/MM/yyyy');
    }

    if (selectedTime != null) {
      _timeStart = selectedTime!.toTimeString();
    } else {
      _timeStart = DateFormat('HH:mm').format(DateTime.now());
    }
  }

  void _fetchTasks({bool isRefresh = false, bool resetPage = false}) {
    if (resetPage) {
      _page = 0;
    }
    _bloc.add(
      StaffRentTaskScreenGetAllTasksEvent(
        isRefresh: isRefresh,
        page: _page,
        query: _searchController.text.trim(),
        isToday: _isToday,
      ),
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    _feedbackController.dispose();
    _addressController.dispose();
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
      _fetchTasks(isRefresh: true, resetPage: true);
    }
    if (state is BookingUpdateErrorState) {
      context.showSnackBar("Cập nhật thất bại!");
    }
  }

  Widget _builder(BuildContext context, state) {
    final tasks = _bloc.staffListAllRentTasks;
    return LoadingIndicator(
      isLoading: _bloc.isLoading && tasks.isEmpty,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Column(
              children: [
                _buildSearchBar(),
                const SizedBox(height: 8),
                _buildFilterRow(),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                _fetchTasks(isRefresh: true, resetPage: true);
              },
              child: tasks.isEmpty && !_bloc.isLoading
                  ? _buildEmptyState()
                  : ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: paddingHorizontal,
                        vertical: 8,
                      ),
                      itemCount:
                          tasks.length +
                          (_bloc.hasMoreAllRentTasks && tasks.isNotEmpty
                              ? 1
                              : 0),
                      itemBuilder: _itemBuilder,
                      separatorBuilder: (BuildContext context, int index) {
                        return const SizedBox(height: 12);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        onSubmitted: (value) {
          _debounceTimer?.cancel();
          _fetchTasks(isRefresh: true, resetPage: true);
        },
        onChanged: (value) {
          setState(() {});
          _debounceTimer?.cancel();
          _debounceTimer = Timer(const Duration(milliseconds: 400), () {
            _fetchTasks(isRefresh: true, resetPage: true);
          });
        },
        decoration: InputDecoration(
          hintText: "Tìm kiếm SĐT, tên, địa chỉ...",
          hintStyle: TextStyle(fontSize: 13.5, color: Colors.grey.shade400),
          prefixIcon: const Icon(
            Icons.search_rounded,
            size: 20,
            color: ColorUtil.graniteGray,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.cancel_rounded,
                    size: 18,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                    _debounceTimer?.cancel();
                    _fetchTasks(isRefresh: true, resetPage: true);
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildFilterRow() {
    return Row(
      children: [
        _buildFilterChip(
          title: "Hôm nay",
          icon: Icons.today_rounded,
          isSelected: _isToday,
          onTap: () {
            if (!_isToday) {
              setState(() {
                _isToday = true;
              });
              _fetchTasks(isRefresh: true, resetPage: true);
            }
          },
        ),
        const SizedBox(width: 8),
        _buildFilterChip(
          title: "Tồn đọng",
          icon: Icons.all_inbox_rounded,
          isSelected: !_isToday,
          onTap: () {
            if (_isToday) {
              setState(() {
                _isToday = false;
              });
              _fetchTasks(isRefresh: true, resetPage: true);
            }
          },
        ),
      ],
    );
  }

  Widget _buildFilterChip({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? ColorUtil.bangladeshGreen.withValues(alpha: 0.12)
              : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? ColorUtil.bangladeshGreen
                : const Color(0xFFE5E7EB),
            width: isSelected ? 1.3 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected
                  ? ColorUtil.bangladeshGreen
                  : const Color(0xFF6B7280),
            ),
            const SizedBox(width: 5),
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
    );
  }

  Widget _itemBuilder(BuildContext context, int index) {
    final tasks = _bloc.staffListAllRentTasks;
    if (index >= tasks.length) {
      return const IndicatorLoadMore();
    }
    TaskModel taskModel = tasks[index];
    return _buildTaskCard(taskModel);
  }

  Widget _buildEmptyState() {
    final hasSearch = _searchController.text.trim().isNotEmpty;
    final message = hasSearch
        ? "Không tìm thấy đơn thuê nào phù hợp với từ khóa \"${_searchController.text.trim()}\""
        : (_isToday
              ? "Chưa có đơn thuê nào trong ngày hôm nay"
              : "Chưa có đơn thuê nào");

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: ColorUtil.bangladeshGreen.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.handshake_rounded,
                      size: 40,
                      color: ColorUtil.bangladeshGreen,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    message,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: ColorUtil.raisinBlack,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Kéo xuống để làm mới danh sách",
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTaskCard(TaskModel taskModel) {
    final statusConfig = _getStatusConfig(taskModel);
    final hasPhone =
        taskModel.customer?.phone != null &&
        taskModel.customer!.phone!.trim().isNotEmpty;
    final hasAddress =
        taskModel.customer?.address != null &&
        taskModel.customer!.address!.trim().isNotEmpty;
    final canUpdate =
        taskModel.status == '1' ||
        taskModel.status == '2' ||
        taskModel.status == '5';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _detailTask(taskModel),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.tag_rounded,
                            size: 13,
                            color: ColorUtil.bangladeshGreen,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            'TH-${taskModel.id ?? 0}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              color: ColorUtil.raisinBlack,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (taskModel.isLongDistanceTask) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF7ED),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFFFEDD5)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.directions_car_filled_outlined,
                              size: 12,
                              color: Color(0xFFEA580C),
                            ),
                            SizedBox(width: 3),
                            Text(
                              'Đi xa',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFEA580C),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const Spacer(),
                    _buildStatusBadge(statusConfig),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  (taskModel.name != null && taskModel.name!.trim().isNotEmpty)
                      ? taskModel.name!
                      : 'Đơn thuê thiết bị',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E2336),
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.access_time_filled_rounded,
                        size: 16,
                        color: ColorUtil.bangladeshGreen,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Thời gian:',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _formatTaskDatetime(taskModel.timeStart),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFDC2626),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.person_rounded,
                            size: 16,
                            color: Color(0xFF6B7280),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              (taskModel.customer?.username != null &&
                                      taskModel.customer!.username!
                                          .trim()
                                          .isNotEmpty)
                                  ? taskModel.customer!.username!
                                  : 'Khách hàng',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1F2937),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (hasPhone) ...[
                            InkWell(
                              onTap: () =>
                                  _makePhoneCall(taskModel.customer?.phone),
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFECFDF5),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: const Color(0xFFA7F3D0),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.phone_in_talk_rounded,
                                      size: 13,
                                      color: Color(0xFF059669),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      taskModel.customer!.phone!,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF059669),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (hasAddress) ...[
                        const SizedBox(height: 8),
                        const Divider(
                          height: 1,
                          thickness: 1,
                          color: Color(0xFFE5E7EB),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 1),
                              child: Icon(
                                Icons.location_on_rounded,
                                size: 16,
                                color: Color(0xFFEF4444),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                taskModel.customer!.address!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF374151),
                                  height: 1.3,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            InkWell(
                              onTap: () =>
                                  _openMap(taskModel.customer?.address),
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: const Color(0xFFD1D5DB),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.directions_rounded,
                                  size: 16,
                                  color: ColorUtil.bangladeshGreen,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                if (taskModel.noti != null &&
                    taskModel.noti!.trim().isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFECACA)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          size: 15,
                          color: Color(0xFFDC2626),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              children: [
                                const TextSpan(
                                  text: 'Thông báo: ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                    color: Color(0xFFDC2626),
                                  ),
                                ),
                                TextSpan(
                                  text: taskModel.noti!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF991B1B),
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (taskModel.des != null &&
                    taskModel.des!.trim().isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.description_outlined,
                          size: 15,
                          color: Color(0xFF6B7280),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              children: [
                                const TextSpan(
                                  text: 'Nội dung: ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                    color: Color(0xFF4B5563),
                                  ),
                                ),
                                TextSpan(
                                  text: taskModel.des!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF374151),
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFF3F4F6),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () => _detailTask(taskModel),
                      borderRadius: BorderRadius.circular(8),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 4,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Xem chi tiết',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: ColorUtil.bangladeshGreen,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 12,
                              color: ColorUtil.bangladeshGreen,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (canUpdate)
                      ElevatedButton.icon(
                        onPressed: () => _updateTask(taskModel),
                        icon: const Icon(
                          Icons.edit_calendar_rounded,
                          size: 15,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Cập nhật',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorUtil.bangladeshGreen,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          minimumSize: const Size(0, 36),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(_TaskStatusConfig config) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: config.bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: config.border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config.icon, size: 12, color: config.text),
          const SizedBox(width: 4),
          Text(
            config.label,
            style: TextStyle(
              color: config.text,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  _TaskStatusConfig _getStatusConfig(TaskModel task) {
    switch (task.status) {
      case "1":
        return _TaskStatusConfig(
          bg: const Color(0xFFF3F4F6),
          text: const Color(0xFF4B5563),
          border: const Color(0xFFE5E7EB),
          icon: Icons.hourglass_top_rounded,
          label: task.getStatus().isNotEmpty ? task.getStatus() : "Chưa giao",
        );
      case "2":
        return _TaskStatusConfig(
          bg: const Color(0xFFFEF3C7),
          text: const Color(0xFFD97706),
          border: const Color(0xFFFDE68A),
          icon: Icons.play_circle_outline_rounded,
          label: task.getStatus().isNotEmpty
              ? task.getStatus()
              : "Đã liên hệ",
        );
      case "3":
        return _TaskStatusConfig(
          bg: const Color(0xFFD1FAE5),
          text: const Color(0xFF059669),
          border: const Color(0xFFA7F3D0),
          icon: Icons.check_circle_outline_rounded,
          label: task.getStatus().isNotEmpty ? task.getStatus() : "Hoàn thành",
        );
      case "4":
        return _TaskStatusConfig(
          bg: const Color(0xFFFEE2E2),
          text: const Color(0xFFDC2626),
          border: const Color(0xFFFECACA),
          icon: Icons.cancel_outlined,
          label: task.getStatus().isNotEmpty ? task.getStatus() : "Đã hủy",
        );
      case "5":
      default:
        return _TaskStatusConfig(
          bg: const Color(0xFFEFF6FF),
          text: const Color(0xFF2563EB),
          border: const Color(0xFFBFDBFE),
          icon: Icons.assignment_ind_outlined,
          label: task.getStatus().isNotEmpty ? task.getStatus() : "Đã giao",
        );
    }
  }

  Future<void> _makePhoneCall(String? phone) async {
    if (phone == null || phone.trim().isEmpty) {
      context.showSnackBar("Số điện thoại không hợp lệ");
      return;
    }
    final cleanPhone = phone.replaceAll(RegExp(r'\s+'), '');
    final uri = Uri.parse('tel:$cleanPhone');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        await launchUrl(uri);
      }
    } catch (e) {
      if (mounted) {
        context.showSnackBar("Không thể thực hiện cuộc gọi");
      }
    }
  }

  Future<void> _openMap(String? address) async {
    if (address == null || address.trim().isEmpty) {
      context.showSnackBar("Địa chỉ không hợp lệ");
      return;
    }
    try {
      final url = '$GOOGLE_MAP_PREFIX${Uri.encodeFull(address.trim())}';
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri);
      }
    } catch (e) {
      if (mounted) {
        context.showSnackBar("Không thể mở ứng dụng bản đồ");
      }
    }
  }

  String _formatTaskDatetime(String? dateTimeString) {
    try {
      if (dateTimeString == null || dateTimeString.isEmpty) {
        return "Chưa cập nhật";
      }
      DateTime getDateTime = DateTime.parse(dateTimeString);
      return DateFormat('HH:mm • dd/MM/yyyy').format(getDateTime);
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
    ).then((_) {
      _fetchTasks(isRefresh: true, resetPage: false);
    });
  }

  Future<void> _updateTask(TaskModel taskModel) async {
    _addressController.text = '';
    _feedbackController.clear();
    int selectedOption = 5;
    DateTime tempDateTime =
        DateTime.tryParse(taskModel.timeStart ?? '') ?? DateTime.now();
    selectedDate = tempDateTime;
    selectedTime = TimeOfDay.fromDateTime(tempDateTime);
    _dateStart = tempDateTime.toDateString(format: "dd/MM/yyyy");
    _timeStart = DateFormat('HH:mm').format(tempDateTime);

    final List<String> quickReasons = [
      'Khách bận hẹn lại giờ khác',
      'Không liên lạc được với khách',
      'Khách thay đổi địa chỉ',
      'Khách yêu cầu hủy đơn thuê',
    ];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 24,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 18, 12, 14),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Color(0xFFF3F4F6),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: ColorUtil.bangladeshGreen.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.edit_calendar_rounded,
                              color: ColorUtil.bangladeshGreen,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Cập nhật & Hẹn lại',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: ColorUtil.raisinBlack,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'TH-${taskModel.id ?? 0}${taskModel.name != null && taskModel.name!.trim().isNotEmpty ? ' • ${taskModel.name}' : ''}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF6B7280),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.pop(dialogContext);
                              _feedbackController.clear();
                              _addressController.clear();
                            },
                            icon: const Icon(
                              Icons.close_rounded,
                              color: Color(0xFF9CA3AF),
                              size: 22,
                            ),
                            splashRadius: 20,
                            tooltip: 'Đóng',
                          ),
                        ],
                      ),
                    ),

                    // Body
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // 1. Trạng thái đơn hàng
                            _buildSectionLabel(
                              icon: Icons.flag_outlined,
                              title: 'Trạng thái xử lý',
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _buildStatusOptionCard(
                                  value: 5,
                                  selectedValue: selectedOption,
                                  label: 'Hẹn lại',
                                  icon: Icons.check_circle_outline_rounded,
                                  activeColor: ColorUtil.bangladeshGreen,
                                  activeBg: const Color(0xFFECFDF5),
                                  onTap: () {
                                    setState(() {
                                      selectedOption = 5;
                                    });
                                  },
                                ),
                                const SizedBox(width: 8),
                                _buildStatusOptionCard(
                                  value: 2,
                                  selectedValue: selectedOption,
                                  label: 'Bỏ đơn',
                                  icon: Icons.assignment_return_outlined,
                                  activeColor: const Color(0xFFD97706),
                                  activeBg: const Color(0xFFFFFBEB),
                                  onTap: () {
                                    setState(() {
                                      selectedOption = 2;
                                    });
                                  },
                                ),
                                const SizedBox(width: 8),
                                _buildStatusOptionCard(
                                  value: 4,
                                  selectedValue: selectedOption,
                                  label: 'Khách hủy',
                                  icon: Icons.cancel_outlined,
                                  activeColor: const Color(0xFFDC2626),
                                  activeBg: const Color(0xFFFEF2F2),
                                  onTap: () {
                                    setState(() {
                                      selectedOption = 4;
                                    });
                                  },
                                ),
                              ],
                            ),

                            const SizedBox(height: 18),

                            // 2. Hẹn lại giờ
                            _buildFormDoubleHorizontal(
                              'Thời gian hẹn lại',
                              Icons.calendar_today_rounded,
                              Icons.access_time_rounded,
                              firstValue: _dateStart,
                              secondValue: _timeStart,
                              onTapFirst: () async {
                                final now = DateTime.now();
                                final today = DateTime(
                                  now.year,
                                  now.month,
                                  now.day,
                                );
                                final initial =
                                    (selectedDate != null &&
                                        !selectedDate!.isBefore(today))
                                    ? selectedDate!
                                    : today;
                                final DateTime? picked = await showDatePicker(
                                  context: context,
                                  locale: const Locale("vi", "VN"),
                                  initialDate: initial,
                                  firstDate: today,
                                  lastDate: today.add(
                                    const Duration(days: 365),
                                  ),
                                );
                                if (picked != null) {
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
                                if (picked != null) {
                                  selectedTime = picked;
                                  setState(() {
                                    final hour = picked.hour.toString().padLeft(
                                      2,
                                      "0",
                                    );
                                    final minute = picked.minute
                                        .toString()
                                        .padLeft(2, "0");
                                    _timeStart = "$hour:$minute";
                                    tempDateTime = DateTime(
                                      tempDateTime.year,
                                      tempDateTime.month,
                                      tempDateTime.day,
                                      picked.hour,
                                      picked.minute,
                                    );
                                  });
                                }
                              },
                            ),

                            const SizedBox(height: 18),

                            // 3. Lý do hẹn lại / Ghi chú
                            _buildSectionLabel(
                              icon: Icons.edit_note_rounded,
                              title: 'Lý do / Ghi chú',
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _feedbackController,
                              maxLines: 3,
                              minLines: 2,
                              onChanged: (_) => setState(() {}),
                              decoration: InputDecoration(
                                hintText:
                                    'Nhập lý do hẹn lại hoặc phản hồi của khách hàng...',
                                hintStyle: const TextStyle(
                                  color: Color(0xFF9CA3AF),
                                  fontSize: 13,
                                ),
                                filled: true,
                                fillColor: const Color(0xFFF9FAFB),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFE5E7EB),
                                    width: 1.0,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: ColorUtil.bangladeshGreen,
                                    width: 1.5,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                              ),
                              style: const TextStyle(
                                fontSize: 13.5,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: quickReasons.map((reason) {
                                final isMatched =
                                    _feedbackController.text.trim() == reason;
                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      _feedbackController.text = reason;
                                      _feedbackController.selection =
                                          TextSelection.fromPosition(
                                            TextPosition(offset: reason.length),
                                          );
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isMatched
                                          ? ColorUtil.bangladeshGreen
                                                .withValues(alpha: 0.1)
                                          : const Color(0xFFF3F4F6),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isMatched
                                            ? ColorUtil.bangladeshGreen
                                            : const Color(0xFFE5E7EB),
                                      ),
                                    ),
                                    child: Text(
                                      reason,
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: isMatched
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                        color: isMatched
                                            ? ColorUtil.bangladeshGreen
                                            : const Color(0xFF4B5563),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),

                            const SizedBox(height: 18),

                            // 4. Địa chỉ mới của khách hàng
                            _buildSectionLabel(
                              icon: Icons.location_on_outlined,
                              title: 'Địa chỉ mới của khách hàng',
                              isOptional: true,
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _addressController,
                              maxLines: 2,
                              minLines: 1,
                              decoration: InputDecoration(
                                hintText:
                                    taskModel.customer?.address != null &&
                                        taskModel.customer!.address!
                                            .trim()
                                            .isNotEmpty
                                    ? 'Hiện tại: ${taskModel.customer!.address}'
                                    : 'Nhập địa chỉ mới nếu khách thay đổi...',
                                hintStyle: const TextStyle(
                                  color: Color(0xFF9CA3AF),
                                  fontSize: 13,
                                ),
                                prefixIcon: const Icon(
                                  Icons.place_outlined,
                                  color: ColorUtil.bangladeshGreen,
                                  size: 20,
                                ),
                                filled: true,
                                fillColor: const Color(0xFFF9FAFB),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFE5E7EB),
                                    width: 1.0,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: ColorUtil.bangladeshGreen,
                                    width: 1.5,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 11,
                                ),
                              ),
                              style: const TextStyle(
                                fontSize: 13.5,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Footer Actions
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Color(0xFFF3F4F6), width: 1),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.pop(dialogContext);
                                _feedbackController.clear();
                                _addressController.clear();
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF4B5563),
                                side: const BorderSide(
                                  color: Color(0xFFD1D5DB),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Hủy bỏ',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                if (_bloc.isClosed) {
                                  _bloc = BlocProvider.of(this.context);
                                }
                                _bloc.add(
                                  StaffTaskScreenUpdateTaskDoneEvent(
                                    taskModel.id ?? 0,
                                    taskModel.name ?? '',
                                    _feedbackController.text.trim(),
                                    taskModel.des ?? '',
                                    selectedOption.toString(),
                                    taskModel.priority ?? "1",
                                    tempDateTime.toString(),
                                    address: _addressController.text.trim(),
                                  ),
                                );

                                if (selectedOption == 2 ||
                                    selectedOption == 4) {
                                  _bloc.staffListTaskBydayModel.removeWhere(
                                    (element) => element.id == taskModel.id,
                                  );
                                }

                                Navigator.pop(dialogContext);
                                _feedbackController.clear();
                                _addressController.clear();
                              },
                              icon: const Icon(
                                Icons.send_rounded,
                                size: 17,
                                color: Colors.white,
                              ),
                              label: const Text(
                                'Lưu cập nhật',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: selectedOption == 4
                                    ? const Color(0xFFDC2626)
                                    : ColorUtil.bangladeshGreen,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSectionLabel({
    required IconData icon,
    required String title,
    bool isOptional = false,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: ColorUtil.bangladeshGreen),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            color: ColorUtil.raisinBlack,
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (isOptional) ...[
          const SizedBox(width: 4),
          const Text(
            '(Tùy chọn)',
            style: TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatusOptionCard({
    required int value,
    required int selectedValue,
    required String label,
    required IconData icon,
    required Color activeColor,
    required Color activeBg,
    required VoidCallback onTap,
  }) {
    final bool isSelected = value == selectedValue;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          decoration: BoxDecoration(
            color: isSelected ? activeBg : const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? activeColor : const Color(0xFFE5E7EB),
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? activeColor : const Color(0xFF6B7280),
              ),
              const SizedBox(height: 5),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? activeColor : const Color(0xFF4B5563),
                ),
              ),
            ],
          ),
        ),
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
        _buildSectionLabel(icon: Icons.schedule_rounded, title: titleTextField),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: InkWell(
                onTap: onTapFirst,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 11,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        iconPrefixFirst,
                        size: 18,
                        color: ColorUtil.bangladeshGreen,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Ngày hẹn',
                              style: TextStyle(
                                fontSize: 10.5,
                                color: Color(0xFF6B7280),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              firstValue.isEmpty ? 'Chọn ngày' : firstValue,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: firstValue.isEmpty
                                    ? const Color(0xFF9CA3AF)
                                    : ColorUtil.raisinBlack,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 18,
                        color: Color(0xFF9CA3AF),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: InkWell(
                onTap: onTapSecond,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 11,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        iconPrefixSecond,
                        size: 18,
                        color: ColorUtil.bangladeshGreen,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Giờ hẹn',
                              style: TextStyle(
                                fontSize: 10.5,
                                color: Color(0xFF6B7280),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              secondValue.isEmpty ? 'Chọn giờ' : secondValue,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: secondValue.isEmpty
                                    ? const Color(0xFF9CA3AF)
                                    : ColorUtil.raisinBlack,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 18,
                        color: Color(0xFF9CA3AF),
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

class _TaskStatusConfig {
  final Color bg;
  final Color text;
  final Color border;
  final IconData icon;
  final String label;

  const _TaskStatusConfig({
    required this.bg,
    required this.text,
    required this.border,
    required this.icon,
    required this.label,
  });
}
