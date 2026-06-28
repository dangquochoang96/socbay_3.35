import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:socbay/utils/image_util.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:socbay/blocs/task_timeline/task_timeline_bloc.dart';
import 'package:socbay/blocs/task_timeline/task_timeline_event.dart';
import 'package:socbay/blocs/task_timeline/task_timeline_state.dart';
import 'package:socbay/data/model/technician_timeline_model.dart';
import 'package:socbay/utils/color_util.dart';
import 'package:socbay/widgets/loading_indicator.dart';
import 'package:socbay/widgets/my_app_bar.dart';

class TaskTimelineScreen extends StatefulWidget {
  const TaskTimelineScreen({super.key});

  @override
  State<TaskTimelineScreen> createState() => _TaskTimelineScreenState();
}

class _TaskTimelineScreenState extends State<TaskTimelineScreen> {
  late TaskTimelineBloc _bloc;
  late DateTime _selectedDate;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _bloc = BlocProvider.of<TaskTimelineBloc>(context);
    _selectedDate = DateTime.now();
    _fetchTimelineData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _fetchTimelineData() {
    _bloc.add(FetchTaskTimeline(date: _selectedDate));
  }

  // Ngày được cố định hôm nay theo yêu cầu

  Color _getStatusColor(String? status) {
    switch (status) {
      case "1":
        return Colors.grey[600]!; // Chưa giao cho ai
      case "2":
        return Colors.orange[800]!; // Đang thực hiện
      case "3":
        return Colors.green[700]!; // Hoàn thành
      case "4":
        return Colors.red[700]!; // Hủy
      case "5":
        return Colors.blue[700]!; // Đã giao
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String? status) {
    switch (status) {
      case "1":
        return "Chưa giao cho ai";
      case "2":
        return "Đang thực hiện";
      case "3":
        return "Hoàn thành";
      case "4":
        return "Hủy";
      case "5":
        return "Đã giao";
      default:
        return "Khác";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: "Timeline Công Việc",
        centerTitle: true,
        backgroundColor: ColorUtil.bangladeshGreen,
      ),
      body: BlocBuilder<TaskTimelineBloc, TaskTimelineState>(
        builder: (context, state) {
          final isLoading = state is TaskTimelineLoading;
          List<TechnicianTimelineModel> allTechnicians = [];

          if (state is TaskTimelineLoaded) {
            allTechnicians = state.technicians;
          }

          // Chỉ giữ những kỹ thuật viên có công việc được giao khi không tìm kiếm
          final techniciansWithTasks = allTechnicians
              .where((tech) => tech.tasks.isNotEmpty)
              .toList();

          // Lọc danh sách kỹ thuật viên từ tất cả kỹ thuật viên nếu có từ khóa tìm kiếm
          final filteredTechnicians = _searchQuery.isEmpty
              ? techniciansWithTasks
              : allTechnicians.where((tech) {
                  final name = tech.username?.toLowerCase() ?? '';
                  final matchesTechName = name.contains(
                    _searchQuery.toLowerCase(),
                  );
                  final matchesTaskAddress = tech.tasks.any(
                    (task) =>
                        task.address?.toLowerCase().contains(
                          _searchQuery.toLowerCase(),
                        ) ??
                        false,
                  );
                  return matchesTechName || matchesTaskAddress;
                }).toList();

          // Tính toán tổng quan số liệu dựa trên các KTV có công việc
          final totalTechs = techniciansWithTasks.length;
          final totalTasks = techniciansWithTasks.fold<int>(
            0,
            (sum, tech) => sum + tech.tasks.length,
          );

          return LoadingIndicator(
            isLoading: isLoading,
            child: Column(
              children: [
                // Bộ lọc ngày và tìm kiếm KTV
                _buildFilterHeader(context),

                // Thống kê nhanh và Chú thích màu sắc
                _buildStatsAndLegend(totalTechs, totalTasks),

                // Thân Calendar hiển thị Timeline
                Expanded(
                  child: state is TaskTimelineError
                      ? _buildErrorWidget(state.message)
                      : allTechnicians.isEmpty && !isLoading
                      ? _buildEmptyWidget()
                      : Padding(
                          padding: const EdgeInsets.only(bottom: 50.0),
                          child: _buildTimelineCalendar(filteredTechnicians),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterHeader(BuildContext context) {
    final dateFormat = DateFormat("EEEE, dd/MM/yyyy", "vi_VN");
    // Trong trường hợp ngôn ngữ chưa được cấu hình locale vi_VN, fallback về format chuẩn
    String dateLabel = '';
    try {
      dateLabel = dateFormat.format(_selectedDate);
    } catch (_) {
      dateLabel = DateFormat("dd/MM/yyyy").format(_selectedDate);
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Ngày cố định hôm nay
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: ColorUtil.bangladeshGreen,
                ),
                const SizedBox(width: 8),
                Text(
                  "Hôm nay: $dateLabel",
                  style: GoogleFonts.roboto(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: ColorUtil.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Ô tìm kiếm KTV
          TextField(
            controller: _searchController,
            onChanged: (val) {
              setState(() {
                _searchQuery = val;
              });
            },
            decoration: InputDecoration(
              hintText: "Tìm kiếm kỹ thuật viên, địa chỉ...",
              prefixIcon: const Icon(
                Icons.search,
                color: ColorUtil.graniteGray,
              ),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(
                        Icons.clear,
                        color: ColorUtil.graniteGray,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 0,
                horizontal: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: const BorderSide(color: ColorUtil.silverChalice),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: const BorderSide(
                  color: ColorUtil.bangladeshGreen,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsAndLegend(int totalTechs, int totalTasks) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.grey[50],
      child: Column(
        children: [
          // Thống kê nhanh
          Wrap(
            spacing: 12,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _buildStatChip(
                Icons.people,
                "Kỹ thuật viên đang làm: $totalTechs",
              ),
              _buildStatChip(
                Icons.assignment,
                "Tổng số công việc đã giao: $totalTasks",
              ),
            ],
          ),
          const Divider(height: 16),
          // Chú thích màu sắc
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildLegendItem("Đã giao", Colors.blue[700]!),
                _buildLegendItem("Đang làm", Colors.orange[800]!),
                _buildLegendItem("Hoàn thành", Colors.green[700]!),
                _buildLegendItem("Hủy", Colors.red[700]!),
                _buildLegendItem("Chưa giao", Colors.grey[600]!),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: ColorUtil.bangladeshGreen),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.roboto(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: ColorUtil.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.roboto(fontSize: 11, color: ColorUtil.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineCalendar(List<TechnicianTimelineModel> technicians) {
    // Chuyển đổi dữ liệu sang dạng Resources và Appointments của SfCalendar
    final List<CalendarResource> calendarResources = [];
    final List<CalendarTaskWrapper> calendarTasks = [];

    for (var tech in technicians) {
      calendarResources.add(
        CalendarResource(
          id: tech.id,
          displayName: (tech.username != null && tech.username!.contains('-'))
              ? tech.username!.split('-').last
              : (tech.username ?? 'KTV ${tech.id}'),
          color: ColorUtil.bangladeshGreen.withValues(alpha: 0.8),
          image: (tech.avatar != null && tech.avatar!.isNotEmpty)
              ? CachedNetworkImageProvider(
                  ImageUtil.getUrlFromPath(tech.avatar!),
                )
              : null,
        ),
      );

      for (var task in tech.tasks) {
        final query = _searchQuery.toLowerCase();
        final techName = tech.username?.toLowerCase() ?? '';
        final taskAddress = task.address?.toLowerCase() ?? '';

        bool shouldShowTask = true;
        if (query.isNotEmpty) {
          final matchesTechName = techName.contains(query);
          final matchesTaskAddress = taskAddress.contains(query);
          shouldShowTask = matchesTechName || matchesTaskAddress;
        }

        if (shouldShowTask) {
          calendarTasks.add(
            CalendarTaskWrapper(
              task: task,
              technicianId: tech.id,
              technician: tech,
            ),
          );
        }
      }
    }

    return SfCalendar(
      key: ValueKey(
        '${_selectedDate.toIso8601String()}_${_searchQuery}_${technicians.length}',
      ),
      view: CalendarView.timelineDay,
      viewNavigationMode: ViewNavigationMode.none,
      headerHeight: 0, // Ẩn header mặc định
      todayHighlightColor: ColorUtil.secondary,
      showNavigationArrow: false,
      showDatePickerButton: false,
      dataSource: TaskCalendarDataSource(calendarTasks, calendarResources),
      resourceViewSettings: ResourceViewSettings(
        showAvatar: true,
        size: 70,
        visibleResourceCount: 4,
        displayNameTextStyle: GoogleFonts.roboto(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: ColorUtil.primary,
        ),
      ),
      timeSlotViewSettings: const TimeSlotViewSettings(
        startHour: 6, // Chỉ show từ 6h sáng
        endHour: 21, // Đến 21h tối
        timeIntervalWidth: 100,
        timeFormat: 'HH:mm',
        timelineAppointmentHeight:
            60, // Thiết lập chiều cao mỗi ô công việc trong timeline
      ),
      appointmentBuilder: _buildAppointment,
      onTap: (CalendarTapDetails details) {
        if (details.targetElement == CalendarElement.resourceHeader) {
          final resource = details.resource;
          if (resource != null) {
            try {
              final tech = technicians.firstWhere((t) => t.id == resource.id);
              _showTechnicianStats(context, tech);
            } catch (_) {}
          }
          return;
        }

        if (details.appointments != null && details.appointments!.isNotEmpty) {
          final wrapper = details.appointments!.first as CalendarTaskWrapper;
          _showTaskDetails(context, wrapper);
        }
      },
    );
  }

  Widget _buildAppointment(
    BuildContext context,
    CalendarAppointmentDetails details,
  ) {
    final wrapper = details.appointments.first as CalendarTaskWrapper;
    final task = wrapper.task;
    final color = _getStatusColor(task.status);

    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxHeight = constraints.maxHeight;
        // Nếu chiều cao ô công việc quá nhỏ (do bị chia nhỏ khi trùng giờ), chỉ hiện tên công việc để tránh overflow
        final bool showSubInfo = maxHeight > 40;

        final double verticalMargin = maxHeight < 30 ? 1 : 2;
        final double verticalPadding = maxHeight < 30 ? 1 : 2;

        return Container(
          margin: EdgeInsets.symmetric(horizontal: 4, vertical: verticalMargin),
          padding: EdgeInsets.symmetric(
            horizontal: 6,
            vertical: verticalPadding,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            border: Border(left: BorderSide(color: color, width: 3)),
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(4),
              bottomRight: Radius.circular(4),
            ),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    task.name ?? 'Công việc dịch vụ',
                    style: GoogleFonts.roboto(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: ColorUtil.primary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (showSubInfo) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 9,
                          color: ColorUtil.primary.withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            task.customerName ?? 'Khách hàng',
                            style: GoogleFonts.roboto(
                              fontSize: 9,
                              color: ColorUtil.primary.withValues(alpha: 0.7),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showTechnicianStats(
    BuildContext context,
    TechnicianTimelineModel tech,
  ) {
    final int totalTasks = tech.tasks.length;
    final int completedTasks = tech.tasks.where((t) => t.status == "3").length;
    final int inProgressTasks = tech.tasks
        .where((t) => t.status == "2" || t.status == "5")
        .length;
    final int cancelledTasks = tech.tasks.where((t) => t.status == "4").length;
    final int unassignedTasks = tech.tasks.where((t) => t.status == "1").length;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Dấu gạch nhỏ phía trên bottom sheet
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // KTV Profile Header
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: ColorUtil.bangladeshGreen,
                          width: 2.5,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.grey[100],
                        backgroundImage:
                            (tech.avatar != null && tech.avatar!.isNotEmpty)
                            ? CachedNetworkImageProvider(
                                ImageUtil.getUrlFromPath(tech.avatar!),
                              )
                            : null,
                        child: (tech.avatar == null || tech.avatar!.isEmpty)
                            ? Icon(
                                Icons.engineering,
                                size: 30,
                                color: ColorUtil.bangladeshGreen,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (tech.username != null &&
                                    tech.username!.contains('-'))
                                ? tech.username!.split('-').last
                                : (tech.username ?? 'Kỹ thuật viên'),
                            style: GoogleFonts.roboto(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: ColorUtil.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Kỹ thuật viên chuyên nghiệp",
                            style: GoogleFonts.roboto(
                              fontSize: 12,
                              color: ColorUtil.graniteGray,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(height: 1),
                const SizedBox(height: 20),

                // Contact info
                Text(
                  "Thông tin liên hệ",
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: ColorUtil.bangladeshGreen,
                  ),
                ),
                const SizedBox(height: 8),
                if (tech.phone != null && tech.phone!.isNotEmpty)
                  _buildInteractiveRow(
                    icon: Icons.phone,
                    title: "Số điện thoại:",
                    value: tech.phone!,
                    isPhone: true,
                    onTap: () => _callPhone(tech.phone),
                  )
                else
                  _buildDetailRow(
                    Icons.phone,
                    "Số điện thoại:",
                    "Không có SĐT",
                  ),
                _buildDetailRow(
                  Icons.location_on,
                  "Địa chỉ làm việc:",
                  tech.address ?? "Chưa cập nhật địa chỉ",
                ),

                const SizedBox(height: 20),
                const Divider(height: 1),
                const SizedBox(height: 20),

                // Statistics Title
                Text(
                  "Thống kê công việc trong ngày",
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: ColorUtil.bangladeshGreen,
                  ),
                ),
                const SizedBox(height: 12),

                // Grid stats
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 1.6,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: [
                    _buildStatCard(
                      title: "Được giao",
                      count: totalTasks,
                      icon: Icons.assignment_outlined,
                      color: Colors.blue[700]!,
                      bgColor: Colors.blue[50]!,
                    ),
                    _buildStatCard(
                      title: "Đang làm",
                      count: inProgressTasks,
                      icon: Icons.play_circle_outline,
                      color: Colors.orange[800]!,
                      bgColor: Colors.orange[50]!,
                    ),
                    _buildStatCard(
                      title: "Hoàn thành",
                      count: completedTasks,
                      icon: Icons.check_circle_outline,
                      color: Colors.green[700]!,
                      bgColor: Colors.green[50]!,
                    ),
                    _buildStatCard(
                      title: "Đã hủy/Khác",
                      count: cancelledTasks + unassignedTasks,
                      icon: Icons.cancel_outlined,
                      color: Colors.red[700]!,
                      bgColor: Colors.red[50]!,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.15),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              Text(
                count.toString(),
                style: GoogleFonts.roboto(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
            ],
          ),
          Text(
            title,
            style: GoogleFonts.roboto(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  void _showTaskDetails(BuildContext context, CalendarTaskWrapper wrapper) {
    final task = wrapper.task;
    final tech = wrapper.technician;
    final statusColor = _getStatusColor(task.status);
    final statusText = _getStatusText(task.status);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Dấu gạch nhỏ phía trên bottom sheet
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                // Header Bottom Sheet
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        task.name ?? 'Chi tiết công việc',
                        style: GoogleFonts.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: ColorUtil.primary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: statusColor),
                      ),
                      child: Text(
                        statusText,
                        style: GoogleFonts.roboto(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "Mã công việc: #${task.id}",
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    color: ColorUtil.graniteGray,
                  ),
                ),
                const Divider(height: 24),

                // Thông tin chi tiết công việc
                _buildDetailRow(
                  Icons.access_time,
                  "Thời gian bắt đầu:",
                  task.timeStart ?? "N/A",
                ),
                _buildDetailRow(
                  Icons.merge_type,
                  "Loại công việc:",
                  task.taskType == "service"
                      ? "Dịch vụ khách hàng"
                      : "Thuê bao",
                ),
                _buildDetailRow(
                  Icons.description,
                  "Mô tả chi tiết:",
                  task.des ?? "Không có mô tả",
                ),

                const Divider(height: 24),

                // Thông tin Khách hàng
                Text(
                  "Thông tin khách hàng",
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: ColorUtil.bangladeshGreen,
                  ),
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  Icons.person,
                  "Tên khách hàng:",
                  task.customerName ?? "Không có tên",
                ),
                _buildInteractiveRow(
                  icon: Icons.phone,
                  title: "Số điện thoại:",
                  value: task.customerPhone ?? "Không có SĐT",
                  isPhone: true,
                  onTap: () => _callPhone(task.customerPhone),
                ),
                _buildInteractiveRow(
                  icon: Icons.location_on,
                  title: "Địa chỉ:",
                  value: task.address ?? "Không có địa chỉ",
                  isAddress: true,
                  onTap: () => _copyToClipboard(
                    task.address ?? '',
                    "Địa chỉ khách hàng",
                  ),
                ),

                const Divider(height: 24),

                // Thông tin Kỹ thuật viên thực hiện
                Text(
                  "Thông tin Kỹ thuật viên",
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: ColorUtil.bangladeshGreen,
                  ),
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  Icons.engineering,
                  "Tên kỹ thuật viên:",
                  tech.username ?? "Không rõ",
                ),
                _buildInteractiveRow(
                  icon: Icons.phone_android,
                  title: "Số điện thoại KTV:",
                  value: tech.phone ?? "Không có SĐT",
                  isPhone: true,
                  onTap: () => _callPhone(tech.phone),
                ),
                _buildDetailRow(
                  Icons.warehouse,
                  "Địa chỉ lấy hàng:",
                  tech.address ?? "Không rõ",
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: ColorUtil.graniteGray),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.roboto(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: ColorUtil.primary,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.roboto(
                fontSize: 13,
                color: ColorUtil.raisinBlack,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveRow({
    required IconData icon,
    required String title,
    required String value,
    bool isPhone = false,
    bool isAddress = false,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: ColorUtil.graniteGray),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.roboto(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: ColorUtil.primary,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: InkWell(
              onTap: onTap,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      value,
                      style: GoogleFonts.roboto(
                        fontSize: 13,
                        color: (isPhone || isAddress)
                            ? Colors.blue[700]
                            : ColorUtil.raisinBlack,
                        decoration: (isPhone || isAddress)
                            ? TextDecoration.underline
                            : TextDecoration.none,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    isPhone ? Icons.call : Icons.copy,
                    size: 14,
                    color: Colors.blue[700],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _callPhone(String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.trim().isEmpty) return;
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'\s+'), '');
    final telUri = Uri.parse('tel:$cleanPhone');
    if (await canLaunchUrl(telUri)) {
      await launchUrl(telUri);
    } else {
      _showSnackBar("Không thể thực hiện cuộc gọi đến số $phoneNumber");
    }
  }

  void _copyToClipboard(String text, String label) {
    if (text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: text)).then((_) {
      _showSnackBar("Đã sao chép $label vào khay nhớ tạm!");
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: ColorUtil.bangladeshGreen,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 12),
            Text(
              error,
              style: GoogleFonts.roboto(
                fontSize: 14,
                color: ColorUtil.raisinBlack,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _fetchTimelineData,
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorUtil.bangladeshGreen,
              ),
              child: const Text(
                "Tải lại",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.event_busy, color: Colors.grey, size: 48),
          const SizedBox(height: 12),
          Text(
            "Không có công việc nào trong ngày này",
            style: GoogleFonts.roboto(
              fontSize: 14,
              color: ColorUtil.graniteGray,
            ),
          ),
        ],
      ),
    );
  }
}

// Wrapper giúp định nghĩa công việc thuộc về KTV nào cho SfCalendar
class CalendarTaskWrapper {
  final TimelineTaskModel task;
  final int technicianId;
  final TechnicianTimelineModel technician;

  CalendarTaskWrapper({
    required this.task,
    required this.technicianId,
    required this.technician,
  });
}

// Calendar Data Source tùy chỉnh
class TaskCalendarDataSource extends CalendarDataSource {
  TaskCalendarDataSource(
    List<CalendarTaskWrapper> source,
    List<CalendarResource> resourceColl,
  ) {
    appointments = source;
    resources = resourceColl;
  }

  @override
  DateTime getStartTime(int index) {
    final wrapper = appointments![index] as CalendarTaskWrapper;
    final startStr = wrapper.task.timeStart;
    if (startStr == null || startStr.isEmpty) return DateTime.now();
    try {
      return DateTime.parse(startStr);
    } catch (_) {
      return DateTime.now();
    }
  }

  @override
  DateTime getEndTime(int index) {
    final wrapper = appointments![index] as CalendarTaskWrapper;
    final startStr = wrapper.task.timeStart;
    final endStr = wrapper.task.timeEnd;

    DateTime start = DateTime.now();
    if (startStr != null && startStr.isNotEmpty) {
      try {
        start = DateTime.parse(startStr);
      } catch (_) {}
    }

    if (endStr == null || endStr.isEmpty || endStr == startStr) {
      // Mặc định công việc kéo dài 1 giờ nếu chưa xong hoặc thời gian start = end
      return start.add(const Duration(hours: 1));
    }
    try {
      final end = DateTime.parse(endStr);
      if (end.isBefore(start)) {
        return start.add(const Duration(hours: 1));
      }
      return end;
    } catch (_) {
      return start.add(const Duration(hours: 1));
    }
  }

  @override
  String getSubject(int index) {
    final wrapper = appointments![index] as CalendarTaskWrapper;
    return wrapper.task.name ?? '';
  }

  @override
  Color getColor(int index) {
    final wrapper = appointments![index] as CalendarTaskWrapper;
    switch (wrapper.task.status) {
      case "1":
        return Colors.grey[600]!;
      case "2":
        return Colors.orange[800]!;
      case "3":
        return Colors.green[700]!;
      case "4":
        return Colors.red[700]!;
      case "5":
        return Colors.blue[700]!;
      default:
        return Colors.grey;
    }
  }

  @override
  List<Object> getResourceIds(int index) {
    final wrapper = appointments![index] as CalendarTaskWrapper;
    return [wrapper.technicianId];
  }
}
