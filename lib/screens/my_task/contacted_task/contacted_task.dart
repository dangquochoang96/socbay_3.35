import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:socbay/blocs/rent-task/rent_task_screen_event.dart';
import 'package:socbay/blocs/rent-task/rent_task_screen_ktv_bloc.dart';
import 'package:socbay/blocs/task/task_screen_bloc.dart';
import 'package:socbay/blocs/task/task_screen_event.dart';
import 'package:socbay/blocs/task/task_screen_state.dart';
import 'package:socbay/constants/maps.dart';
import 'package:socbay/data/model/task_model.dart';
import 'package:socbay/utils/color_util.dart';
import 'package:socbay/utils/context_extension.dart';
import 'package:socbay/utils/scroll_util.dart';
import 'package:socbay/widgets/indicator_loadmore.dart';
import 'package:socbay/widgets/loading_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactedTaskTab extends StatefulWidget {
  const ContactedTaskTab({super.key});

  @override
  State<ContactedTaskTab> createState() => _ContactedTaskTabState();
}

class _ContactedTaskTabState extends State<ContactedTaskTab> {
  late TaskScreenBloc _bloc;
  late ScrollController _scrollController;
  late TextEditingController _searchController;

  Timer? _debounceTimer;
  int _page = 0;
  bool _isToday = true;

  @override
  void initState() {
    super.initState();
    _bloc = BlocProvider.of<TaskScreenBloc>(context);
    _scrollController = ScrollController();
    _searchController = TextEditingController();

    _fetchTasks(isRefresh: true, resetPage: true);

    _scrollController.addListener(() {
      if (_bloc.isClosed) _bloc = BlocProvider.of<TaskScreenBloc>(context);
      scrollPaginationListener(
        scrollController: _scrollController,
        condition:
            (_scrollController.hasClients &&
                _scrollController.position.pixels >=
                    _scrollController.position.maxScrollExtent - 80) &&
            !_bloc.isLoading &&
            _bloc.hasMoreContactedTasks,
        paginationFunction: () {
          _page++;
          _fetchTasks(isRefresh: false, resetPage: false);
        },
      );
    });
  }

  void _fetchTasks({bool isRefresh = false, bool resetPage = false}) {
    if (resetPage) {
      _page = 0;
    }
    _bloc.add(
      StaffTaskScreenGetContactedTasksEvent(
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TaskScreenBloc, TaskScreenState>(
      builder: _builder,
      listener: _listener,
    );
  }

  void _listener(BuildContext context, TaskScreenState state) {
    if (state is AcceptContactedTaskSuccessState) {
      final msg = (state.message != null && state.message!.trim().isNotEmpty)
          ? state.message!
          : "Nhận đơn thành công!";
      context.showSnackBar(msg);
      _fetchTasks(isRefresh: true, resetPage: true);
      _bloc.add(
        const StaffTaskScreenGetAllTasksEvent(
          isRefresh: true,
          page: 0,
          isToday: true,
        ),
      );
      try {
        final rentBloc = BlocProvider.of<RentTaskScreenKTVBloc>(
          context,
          listen: false,
        );
        if (!rentBloc.isClosed) {
          rentBloc.add(
            const StaffRentTaskScreenGetAllTasksEvent(
              isRefresh: true,
              page: 0,
              isToday: true,
            ),
          );
        }
      } catch (_) {}
    }
    if (state is AcceptContactedTaskErrorState) {
      final msg = (state.message != null && state.message!.trim().isNotEmpty)
          ? state.message!
          : "Nhận đơn thất bại! Vui lòng thử lại.";
      context.showSnackBar(msg);
    }
  }

  Widget _builder(BuildContext context, TaskScreenState state) {
    final tasks = _bloc.staffListContactedTasks;
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
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      itemCount:
                          tasks.length + (_bloc.hasMoreContactedTasks ? 1 : 0),
                      itemBuilder: _itemBuilder,
                      separatorBuilder: (context, index) {
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
          hintText: "Tìm kiếm SĐT, tên, địa chỉ, mã...",
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
              : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? ColorUtil.bangladeshGreen.withValues(alpha: 0.5)
                : const Color(0xFFE5E7EB),
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
    final tasks = _bloc.staffListContactedTasks;
    if (index >= tasks.length) {
      return const IndicatorLoadMore();
    }
    final taskModel = tasks[index];
    return _buildTaskCard(taskModel);
  }

  Widget _buildEmptyState() {
    final hasSearch = _searchController.text.trim().isNotEmpty;
    final message = hasSearch
        ? "Không tìm thấy công việc đã liên hệ nào phù hợp với từ khóa \"${_searchController.text.trim()}\""
        : (_isToday
              ? "Chưa có công việc đã liên hệ nào trong ngày hôm nay"
              : "Chưa có công việc đã liên hệ nào");

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.phone_callback_rounded,
                      size: 38,
                      color: Color(0xFF8B5CF6),
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
    final isRent = taskModel.isRent == true;
    final hasPhone =
        taskModel.customer?.phone != null &&
        taskModel.customer!.phone!.trim().isNotEmpty;
    final address = taskModel.customer?.address ?? taskModel.currentAddress;
    final hasAddress = address != null && address.trim().isNotEmpty;
    final hasDes = taskModel.des != null && taskModel.des!.trim().isNotEmpty;

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
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Tag & Badges Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 5,
                    runSpacing: 5,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      // Code Tag
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3.5,
                        ),
                        decoration: BoxDecoration(
                          color: isRent
                              ? const Color(0xFFFFFBEB)
                              : const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isRent
                                ? const Color(0xFFFDE68A)
                                : const Color(0xFFE5E7EB),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.tag_rounded,
                              size: 12,
                              color: isRent
                                  ? const Color(0xFFD97706)
                                  : ColorUtil.bangladeshGreen,
                            ),
                            const SizedBox(width: 2.5),
                            Text(
                              isRent
                                  ? 'THUÊ-${taskModel.id ?? 0}'
                                  : 'DV-${taskModel.id ?? 0}',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 11.5,
                                color: isRent
                                    ? const Color(0xFFB45309)
                                    : ColorUtil.raisinBlack,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Task Type Badge (Đơn dịch vụ vs Đơn thuê)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3.5,
                        ),
                        decoration: BoxDecoration(
                          color: isRent
                              ? const Color(0xFFFEF3C7)
                              : const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isRent
                                ? const Color(0xFFFCD34D)
                                : const Color(0xFFBFDBFE),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isRent
                                  ? Icons.handshake_rounded
                                  : Icons.home_repair_service_rounded,
                              size: 11,
                              color: isRent
                                  ? const Color(0xFFB45309)
                                  : const Color(0xFF1D4ED8),
                            ),
                            const SizedBox(width: 3.5),
                            Text(
                              isRent ? 'Đơn thuê' : 'Đơn dịch vụ',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isRent
                                    ? const Color(0xFFB45309)
                                    : const Color(0xFF1D4ED8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (taskModel.priority == '2')
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6.5,
                            vertical: 3.5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFFECACA)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.bolt_rounded,
                                size: 12,
                                color: Color(0xFFDC2626),
                              ),
                              SizedBox(width: 2),
                              Text(
                                'Gấp',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFDC2626),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (taskModel.isLongDistanceTask)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6.5,
                            vertical: 3.5,
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
                                size: 11,
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
                  ),
                ),
                const SizedBox(width: 6),
                // Status Badge: "Đã liên hệ"
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3.5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3E8FF),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE9D5FF)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.phone_callback_rounded,
                        size: 11.5,
                        color: Color(0xFF7E22CE),
                      ),
                      SizedBox(width: 3.5),
                      Text(
                        'Đã liên hệ',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF7E22CE),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Task Name
            Text(
              (taskModel.name != null && taskModel.name!.trim().isNotEmpty)
                  ? taskModel.name!
                  : (isRent ? 'Công việc cho thuê' : 'Công việc dịch vụ'),
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
            // Time Box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                    color: Color(0xFF7E22CE),
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
            // Customer & Address Box
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
                            address,
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
                          onTap: () => _openMap(address),
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
            // Product info (if present)
            if (taskModel.productInfo != null &&
                taskModel.productInfo!.name != null &&
                taskModel.productInfo!.name!.trim().isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFDCFCE7)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(
                        Icons.inventory_2_outlined,
                        size: 14,
                        color: Color(0xFF16A34A),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Thiết bị: ${taskModel.productInfo!.name!.trim()}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF15803D),
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            // Note from Sale (if present)
            if (hasDes) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFEF3C7)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(
                        Icons.sticky_note_2_outlined,
                        size: 14,
                        color: Color(0xFFB45309),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Ghi chú sale: ${taskModel.des!.trim()}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF92400E),
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            // Button: "Nhận việc"
            SizedBox(
              width: double.infinity,
              height: 42,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorUtil.bangladeshGreen,
                  foregroundColor: Colors.white,
                  elevation: 1.5,
                  shadowColor: ColorUtil.bangladeshGreen.withValues(alpha: 0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => _onClaimTask(taskModel),
                icon: const Icon(Icons.how_to_reg_rounded, size: 18),
                label: const Text(
                  "Nhận việc",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onClaimTask(TaskModel taskModel) {
    final bool isRent =
        taskModel.isRent == true || taskModel.taskType == 'rent';
    final String taskCode = isRent
        ? 'THUÊ-${taskModel.id ?? 0}'
        : 'DV-${taskModel.id ?? 0}';
    final String taskName =
        (taskModel.name != null && taskModel.name!.trim().isNotEmpty)
        ? taskModel.name!.trim()
        : (isRent ? 'Công việc cho thuê' : 'Công việc dịch vụ');

    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: ColorUtil.bangladeshGreen.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.how_to_reg_rounded,
                      size: 28,
                      color: ColorUtil.bangladeshGreen,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Xác nhận nhận đơn',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: ColorUtil.raisinBlack,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: Color(0xFF4B5563),
                        height: 1.4,
                      ),
                      children: [
                        const TextSpan(text: 'Bạn có chắc chắn muốn nhận đơn '),
                        TextSpan(
                          text: taskCode,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: ColorUtil.bangladeshGreen,
                          ),
                        ),
                        TextSpan(
                          text: ' ($taskName)',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const TextSpan(text: ' không?'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF4B5563),
                            side: const BorderSide(color: Color(0xFFD1D5DB)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Hủy',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(dialogContext);
                            if (_bloc.isClosed) {
                              _bloc = BlocProvider.of<TaskScreenBloc>(context);
                            }
                            _bloc.add(
                              StaffTaskScreenAcceptContactedTaskEvent(
                                taskId: taskModel.id ?? 0,
                                taskType: taskModel.taskType,
                                isRent: taskModel.isRent,
                                des: taskModel.des,
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.check_circle_outline_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'Nhận đơn',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorUtil.bangladeshGreen,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
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
      debugPrint("format datetime error: $ex");
      return dateTimeString ?? "";
    }
  }
}
