import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:socbay/blocs/rent-task/rent_task_screen_ktv_bloc.dart';
import 'package:socbay/blocs/rent-task/rent_task_screen_event.dart';
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
import 'package:socbay/widgets/button_widget.dart';
import 'package:socbay/widgets/indicator_loadmore.dart';
import 'package:socbay/widgets/loading_indicator.dart';

class RentTaskAvailableTab extends StatefulWidget {
  const RentTaskAvailableTab({super.key});

  @override
  State<RentTaskAvailableTab> createState() => _RentTaskAvailableTabState();
}

class _RentTaskAvailableTabState extends State<RentTaskAvailableTab> {
  late RentTaskScreenKTVBloc _bloc;
  late ScrollController _scrollController;
  late TextEditingController _feedbackController;
  late TextEditingController _addressController;
  int _page = 0;
  String _dateStart = '';
  String _timeStart = '';

  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  @override
  void initState() {
    super.initState();
    _bloc = BlocProvider.of(context);
    _bloc.add(StaffTaskScreenGetTaskAssigedEvent(page: _page));
    _scrollController = ScrollController();
    _feedbackController = TextEditingController();
    _addressController = TextEditingController();
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
          _page++;
          _bloc.add(StaffTaskScreenGetTaskAssigedEvent(page: _page));
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
        _timeStart = DateFormat('HH:mm').format(DateTime.now());
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
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
      _bloc.add(const StaffTaskScreenGetTaskByDayEvent(isRefresh: true));
    }
    if (state is BookingUpdateErrorState) {
      context.showSnackBar("Cập nhật thất bại!");
    }
    if (state is BookingDeleteSuccessState) {
      context.showSnackBar("Hủy thành công!");
    }
    if (state is BookingDeleteErrorState) {
      context.showSnackBar("Hủy thất bại!");
    }
    if (state is MyTaskScreenInitialState) {
      setState(() {});
    }
  }

  Widget _builder(BuildContext context, state) {
    final tasks = _bloc.staffListTaskAssigedModel;
    return LoadingIndicator(
      isLoading: _bloc.isLoading,
      child: RefreshIndicator(
        onRefresh: () async {
          _page = 0;
          _bloc.add(
            const StaffTaskScreenGetTaskAssigedEvent(isRefresh: true, page: 0),
          );
        },
        child: tasks.isEmpty && !_bloc.isLoading
            ? _buildEmptyState()
            : ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                controller: _scrollController,
                itemBuilder: _itemBuilder,
                itemCount: tasks.length,
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
    if (index >= _bloc.staffListTaskAssigedModel.length) {
      return const IndicatorLoadMore();
    }
    TaskModel taskModel = _bloc.staffListTaskAssigedModel[index];
    return _buildTaskCard(taskModel);
  }

  Widget _buildEmptyState() {
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
                      Icons.history_toggle_off_rounded,
                      size: 40,
                      color: ColorUtil.bangladeshGreen,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Chưa có đơn thuê tồn đọng",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: ColorUtil.raisinBlack,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Các đơn thuê thiết bị tồn đọng sẽ hiển thị tại đây.\nKéo xuống để làm mới danh sách.",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
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
    );
  }

  Future<void> _updateTask(TaskModel taskModel) async {
    _addressController.text = '';
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
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              title: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history_toggle_off,
                    color: ColorUtil.bangladeshGreen,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Lý do hẹn lại',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ColorUtil.raisinBlack,
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
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
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
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
                            print("X6");
                            print(tempDateTime);
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _addressController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Địa chỉ mới của khách hàng',
                        labelStyle: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                        hintText: 'Nhập địa chỉ mới của khách hàng (nếu có)',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 13,
                        ),
                        prefixIcon: const Icon(
                          Icons.location_on_outlined,
                          color: ColorUtil.bangladeshGreen,
                          size: 20,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
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
                          vertical: 10,
                        ),
                      ),
                      style: const TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _feedbackController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Lý do',
                        labelStyle: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                        hintText: 'Nhập lý do hẹn lại',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 13,
                        ),
                        prefixIcon: const Icon(
                          Icons.edit_note_outlined,
                          color: ColorUtil.bangladeshGreen,
                          size: 20,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
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
                          vertical: 10,
                        ),
                      ),
                      style: const TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Trạng thái đơn hàng',
                      style: TextStyle(
                        color: ColorUtil.raisinBlack,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [5, 1, 2].map((val) {
                        final isSelected = selectedOption == val;
                        String label = '';
                        if (val == 5) label = 'Nhận Đơn';
                        if (val == 1) label = 'Không nhận Đơn';
                        if (val == 2) label = 'Khách hàng hủy';
                        return ChoiceChip(
                          label: Text(
                            label,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 13,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: ColorUtil.bangladeshGreen,
                          backgroundColor: Colors.grey.shade100,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected
                                  ? ColorUtil.bangladeshGreen
                                  : Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                          onSelected: (bool selected) {
                            if (selected) {
                              setState(() {
                                selectedOption = val;
                              });
                            }
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
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
                        _addressController.clear();
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
                            StaffTaskScreenUpdateTaskDayDoneEvent(
                              taskModel.id ?? 0,
                              taskModel.name!,
                              _feedbackController.text,
                              taskModel.des ?? '',
                              selectedOption.toString(),
                              taskModel.priority ?? "1",
                              tempDateTime.toString(),
                              address: _addressController.text,
                            ),
                          );

                          _bloc.staffListTaskAssigedModel.removeWhere(
                            (element) => element.id == taskModel.id,
                          );

                          Navigator.pop(context);
                          _feedbackController.clear();
                          _addressController.clear();
                        } else {
                          _bloc.add(
                            StaffTaskScreenUpdateTaskDayDoneEvent(
                              taskModel.id ?? 0,
                              taskModel.name!,
                              _feedbackController.text,
                              taskModel.des ?? '',
                              selectedOption.toString(),
                              taskModel.priority ?? "1",
                              tempDateTime.toString(),
                              address: _addressController.text,
                            ),
                          );

                          Navigator.pop(context);
                          _feedbackController.clear();
                          _addressController.clear();
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
          style: const TextStyle(
            color: ColorUtil.raisinBlack,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: GestureDetector(
                onTap: onTapFirst,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        iconPrefixFirst,
                        size: 20,
                        color: ColorUtil.bangladeshGreen,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          firstValue.isEmpty ? 'Chọn ngày' : firstValue,
                          style: TextStyle(
                            fontSize: 13,
                            color: firstValue.isEmpty
                                ? Colors.grey.shade400
                                : ColorUtil.raisinBlack,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: GestureDetector(
                onTap: onTapSecond,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        iconPrefixSecond,
                        size: 20,
                        color: ColorUtil.bangladeshGreen,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          secondValue.isEmpty ? 'Giờ' : secondValue,
                          style: TextStyle(
                            fontSize: 13,
                            color: secondValue.isEmpty
                                ? Colors.grey.shade400
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

