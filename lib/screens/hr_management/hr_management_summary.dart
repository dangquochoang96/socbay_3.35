import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:socbay/application.dart';
import 'package:socbay/blocs/hr_management/hr_management_bloc.dart';
import 'package:socbay/blocs/hr_management/hr_management_event.dart';
import 'package:socbay/blocs/hr_management/hr_management_state.dart';
import 'package:socbay/config/app_config.dart';
import 'package:socbay/data/model/kpi_model.dart';
import 'package:socbay/data/model/user_attendance_model.dart';
import 'package:socbay/data/model/user_profile.dart';
import 'package:socbay/utils/color_util.dart';
import 'package:socbay/widgets/loading_indicator.dart';
import 'package:socbay/widgets/my_app_bar.dart';

class HRManagementSummaryScreen extends StatefulWidget {
  const HRManagementSummaryScreen({super.key});

  @override
  State<HRManagementSummaryScreen> createState() =>
      _HRManagementSummaryScreenState();
}

class _HRManagementSummaryScreenState extends State<HRManagementSummaryScreen>
    with TickerProviderStateMixin {
  late HRManagementBloc _bloc;
  late DateTime selectedDate;
  late List<DateTime> availableMonths;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _bloc = BlocProvider.of<HRManagementBloc>(context);
    _tabController = TabController(length: 4, vsync: this);
    selectedDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
    _initializeAvailableMonths();
    _loadData();
  }

  void _loadData() {
    final userId = App.instance.userApp?.id?.toString();
    if (userId != null) {
      _bloc.add(FetchHRManagementData(userId: userId));
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _initializeAvailableMonths() {
    final now = DateTime.now();
    availableMonths = [
      DateTime(now.year, now.month, 1),
      DateTime(now.year, now.month - 1 <= 0 ? 12 : now.month - 1, 1),
      DateTime(now.year, now.month - 2 <= 0 ? 11 : now.month - 2, 1),
    ];

    if (now.month - 1 <= 0) {
      availableMonths[1] = DateTime(now.year - 1, 12, 1);
    }
    if (now.month - 2 <= 0) {
      availableMonths[2] = DateTime(now.year - 1, now.month - 2 + 12, 1);
    }
  }

  void _onMonthChanged(DateTime newDate) {
    setState(() {
      selectedDate = newDate;
    });
  }

  bool _isCurrentMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HRManagementBloc, HRManagementState>(
      listener: (context, state) {
        if (state is HRManagementError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message,
                style: GoogleFonts.roboto(color: Colors.white),
              ),
              backgroundColor: ColorUtil.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is HRManagementLoading;
        UserProfile? userProfile;
        UserProfile? userInfoProfile;
        if (state is HRManagementLoaded) {
          userProfile = state.userProfile;
          userInfoProfile = state.userInfoProfile;
        }

        return Scaffold(
          appBar: MyAppBar(
            title: 'Chấm công & KPI',
            isBackNavigation: true,
            actionWidgets: [
              IconButton(
                onPressed: isLoading ? null : _loadData,
                icon: const Icon(Icons.refresh, color: Colors.white),
                tooltip: 'Làm mới',
              ),
            ],
          ),
          body: LoadingIndicator(
            isLoading: isLoading,
            child: Container(
              color: const Color(0xFFF7F9FC),
              child: SafeArea(
                child: Column(
                  children: [
                    if (userProfile != null) _buildProfileHeader(userProfile),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: _buildMonthSelector(),
                    ),
                    _buildTabBar(),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildTimeAttendanceTab(userProfile),
                          _buildWorkContentTab(userProfile),
                          _buildKPITab(userProfile),
                          _buildIncomeTab(userProfile, userInfoProfile),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(UserProfile profile) {
    final username =
        profile.user?.username ?? App.instance.userApp?.username ?? 'Nhân viên';
    final avatar = profile.user?.avatar ?? App.instance.userApp?.avatar ?? '';
    // final level = profile.level ?? 'Kỹ thuật viên';
    // final description = profile.description ?? 'Chưa có mô tả';
    final userRole = App.instance.userApp?.typeStaff;

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: const BoxDecoration(
        color: ColorUtil.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: ColorUtil.bangladeshGreen.withValues(alpha: 0.1),
            backgroundImage: avatar.isNotEmpty
                ? NetworkImage(
                    '$protocol${AppConfig.instance.values.apiUrl}$avatar',
                  )
                : null,
            child: avatar.isEmpty
                ? const Icon(
                    Icons.person,
                    size: 36,
                    color: ColorUtil.bangladeshGreen,
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  username,
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ColorUtil.raisinBlack,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  // decoration: BoxDecoration(
                  //   color: ColorUtil.bangladeshGreen.withValues(alpha: 0.1),
                  //   borderRadius: BorderRadius.circular(12),
                  // ),
                  // child: Text(
                  //   level,
                  //   style: GoogleFonts.roboto(
                  //     fontSize: 12,
                  //     fontWeight: FontWeight.w600,
                  //     color: ColorUtil.bangladeshGreen,
                  //   ),
                  // ),
                ),
                const SizedBox(height: 6),
                Text(
                  userRole == "0"
                      ? 'Khách hàng'
                      : userRole == "1"
                      ? 'Kỹ Thuật'
                      : userRole == "2"
                      ? 'Kinh Doanh'
                      : userRole == "3"
                      ? 'Giao Hàng'
                      : userRole == "5"
                      ? 'Kho'
                      : userRole == "4"
                      ? 'Kế Toán'
                      : userRole == "6"
                      ? 'Marketing'
                      : userRole == "7"
                      ? 'CNTT'
                      : userRole == "8"
                      ? 'Nhân Sự'
                      : 'Người dùng',
                  style: GoogleFonts.roboto(
                    fontSize: 13,
                    color: ColorUtil.graniteGray,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: selectedDate.month + selectedDate.year * 100,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: ColorUtil.bangladeshGreen,
          ),
          style: GoogleFonts.roboto(
            fontSize: 16,
            color: ColorUtil.raisinBlack,
            fontWeight: FontWeight.w500,
          ),
          items: availableMonths.map((DateTime date) {
            final isCurrentMonth = _isCurrentMonth(date);
            return DropdownMenuItem<int>(
              value: date.month + date.year * 100,
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_month,
                    size: 20,
                    color: ColorUtil.bangladeshGreen,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Tháng ${date.month}/${date.year}',
                    style: GoogleFonts.roboto(
                      fontSize: 15,
                      color: isCurrentMonth
                          ? ColorUtil.bangladeshGreen
                          : ColorUtil.raisinBlack,
                      fontWeight: isCurrentMonth
                          ? FontWeight.bold
                          : FontWeight.w500,
                    ),
                  ),
                  if (isCurrentMonth) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: ColorUtil.bangladeshGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Hiện tại',
                        style: GoogleFonts.roboto(
                          fontSize: 10,
                          color: ColorUtil.bangladeshGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
          onChanged: (int? newValue) {
            if (newValue != null) {
              final year = newValue ~/ 100;
              final month = newValue % 100;
              _onMonthChanged(DateTime(year, month, 1));
            }
          },
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: ColorUtil.bangladeshGreen,
        unselectedLabelColor: ColorUtil.graniteGray,
        indicatorColor: ColorUtil.bangladeshGreen,
        indicatorWeight: 3,
        labelStyle: GoogleFonts.roboto(
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
        unselectedLabelStyle: GoogleFonts.roboto(
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
        tabs: const [
          Tab(
            icon: Icon(Icons.access_time_filled, size: 20),
            text: 'Chấm Công',
          ),
          Tab(icon: Icon(Icons.description, size: 20), text: 'Công Việc'),
          Tab(icon: Icon(Icons.analytics, size: 20), text: 'KPI'),
          Tab(
            icon: Icon(Icons.account_balance_wallet, size: 20),
            text: 'Thu Nhập',
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Không có dữ liệu',
              style: GoogleFonts.roboto(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: ColorUtil.graniteGray,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tháng ${selectedDate.month}/${selectedDate.year}',
              style: GoogleFonts.roboto(
                fontSize: 13,
                color: ColorUtil.spanishGray,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to format currency
  String _formatCurrency(dynamic val, {bool isNumber = false}) {
    if (val == null) return '0 ₫';
    final number = int.tryParse(val.toString()) ?? 0;
    if (isNumber) {
      return NumberFormat('#,###').format(number);
    }
    return '${NumberFormat('#,###').format(number)} ₫';
  }

  // Filter schedules by selected month and year
  List<WorkSchedules> _getFilteredSchedules(UserProfile? profile) {
    if (profile?.userAttendances == null) return [];

    for (final att in profile!.userAttendances!) {
      final attMonthVal = int.tryParse(att.month ?? '');
      final attYearVal = int.tryParse(att.year ?? '');
      if (attMonthVal == selectedDate.month &&
          attYearVal == selectedDate.year) {
        return att.workSchedules ?? [];
      }
    }
    return [];
  }

  List<KPIs> _getKPIsForSelectedMonth(UserProfile? profile) {
    if (profile?.kpi?.data == null) return [];
    final monthKey = DateFormat('yyyy-MM').format(selectedDate);
    return profile!.kpi!.data[monthKey] ?? [];
  }

  // Tab 1: Time Attendance details
  Widget _buildTimeAttendanceTab(UserProfile? profile) {
    final schedules = _getFilteredSchedules(profile);
    if (schedules.isEmpty) return _buildNoDataMessage();

    final totalDays = schedules.fold<num>(
      0,
      (sum, s) => sum + (s.isHoliday ?? 0),
    );
    final workingDays = schedules.fold<num>(
      0,
      (sum, s) => sum + (s.workingDay ?? 0),
    );
    final missingDays = totalDays - workingDays;
    final lateDays = schedules.where((s) => (s.lateMinutes ?? 0) > 0).length;
    final earlyLeaveDays = schedules
        .where((s) => (s.earlyLeaveMinutes ?? 0) > 0)
        .length;
    // final totalWorkingHours = schedules.fold<num>(
    //   0,
    //   (sum, s) => sum + (s.totalWorkHours ?? 0),
    // );
    // final overtimeHours = schedules.fold<num>(
    //   0,
    //   (sum, s) => sum + (s.overtimeHours ?? 0),
    // );
    // final companyOvertimeHours = schedules.fold<num>(
    //   0,
    //   (sum, s) => sum + (s.companyOvertimeHours ?? 0),
    // );

    final summaryItems = [
      {
        'label': 'Tổng ngày công định mức',
        'value': '$totalDays ngày',
        'icon': Icons.calendar_month,
      },
      {
        'label': 'Số ngày thực tế làm việc',
        'value': '$workingDays ngày',
        'icon': Icons.check_circle_outline,
      },
      {
        'label': 'Chênh lệch ngày công',
        'value': '${missingDays.abs()} ngày',
        'isDeduction': missingDays > 0,
        'icon': Icons.warning_amber_rounded,
      },
      // {
      //   'label': 'Tổng số giờ làm việc',
      //   'value': '$totalWorkingHours giờ',
      //   'icon': Icons.hourglass_empty,
      // },
      {
        'label': 'Ngày đi muộn',
        'value': '$lateDays ngày',
        'isDeduction': lateDays > 0,
        'icon': Icons.running_with_errors,
      },
      {
        'label': 'Ngày về sớm',
        'value': '$earlyLeaveDays ngày',
        'isDeduction': earlyLeaveDays > 0,
        'icon': Icons.logout_outlined,
      },
      // {
      //   'label': 'Giờ tăng ca cá nhân',
      //   'value': '$overtimeHours giờ',
      //   'icon': Icons.add_circle_outline,
      // },
      // {
      //   'label': 'Giờ tăng ca công ty',
      //   'value': '$companyOvertimeHours giờ',
      //   'icon': Icons.business,
      // },
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: summaryItems.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = summaryItems[index];
        final isDeduction = item['isDeduction'] == true;
        final icon = item['icon'] as IconData;

        return Card(
          elevation: 0.5,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade100),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isDeduction
                      ? Colors.red.shade400
                      : ColorUtil.bangladeshGreen,
                  size: 22,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    item['label'] as String,
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: ColorUtil.raisinBlack,
                    ),
                  ),
                ),
                Text(
                  item['value'] as String,
                  style: GoogleFonts.roboto(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDeduction
                        ? Colors.red.shade600
                        : ColorUtil.bangladeshGreen,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Tab 2: Work Content description & Yearly KPI
  Widget _buildWorkContentTab(UserProfile? profile) {
    final description = profile?.description ?? 'Chưa có mô tả công việc';
    final endYearKPI = profile?.endYearKPI?.data;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 0.5,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade100),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.assignment_outlined,
                        color: ColorUtil.bangladeshGreen,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Mô tả công việc',
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: ColorUtil.raisinBlack,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Text(
                    description,
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      color: ColorUtil.graniteGray,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'KPI theo năm',
            style: GoogleFonts.roboto(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ColorUtil.raisinBlack,
            ),
          ),
          const SizedBox(height: 10),
          if (endYearKPI == null || endYearKPI.isEmpty)
            Card(
              elevation: 0.5,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade100),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Center(
                  child: Text(
                    'Chưa có dữ liệu KPI theo năm',
                    style: GoogleFonts.roboto(color: ColorUtil.spanishGray),
                  ),
                ),
              ),
            )
          else
            ...endYearKPI.entries.map((entry) {
              final year = entry.key;
              final kpisList = entry.value;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Năm $year',
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: ColorUtil.bangladeshGreen,
                      ),
                    ),
                  ),
                  ...kpisList.map((kpi) => _buildKPITile(kpi)),
                ],
              );
            }),
        ],
      ),
    );
  }

  // Tab 3: KPI Monthly details
  Widget _buildKPITab(UserProfile? profile) {
    final kpis = _getKPIsForSelectedMonth(profile);
    if (kpis.isEmpty) return _buildNoDataMessage();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: kpis.length,
      itemBuilder: (context, index) {
        return _buildKPITile(kpis[index]);
      },
    );
  }

  Widget _buildKPITile(KPIs kpi) {
    final name = kpi.name ?? 'Chỉ tiêu';
    final percent = kpi.percent ?? 0;
    final achieved = kpi.achieved ?? '0';
    final target = kpi.target ?? '0';
    final unit = kpi.unit ?? '';
    final notes = kpi.notes ?? 'Không có ghi chú';
    final bonus = kpi.salaryBonus ?? 0;

    return Card(
      elevation: 0.5,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade100),
      ),
      child: ExpansionTile(
        title: Text(
          name,
          style: GoogleFonts.roboto(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: ColorUtil.raisinBlack,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Đạt được: $percent%',
                    style: GoogleFonts.roboto(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: percent >= 100
                          ? Colors.green.shade600
                          : Colors.orange.shade600,
                    ),
                  ),
                  Text(
                    'Thưởng: ${_formatCurrency(bonus)}',
                    style: GoogleFonts.roboto(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: ColorUtil.bangladeshGreen,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: percent / 100.0,
                  backgroundColor: Colors.grey.shade100,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    percent >= 100 ? Colors.green : ColorUtil.brightYellow,
                  ),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildDetailRow('Đơn vị đo', unit),
                _buildDetailRow(
                  'Mục tiêu',
                  _formatCurrency(target, isNumber: true),
                ),
                _buildDetailRow(
                  'Đạt được',
                  _formatCurrency(achieved, isNumber: true),
                ),
                _buildDetailRow('Ghi chú', notes),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.roboto(
              fontSize: 13,
              color: ColorUtil.graniteGray,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.roboto(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: ColorUtil.raisinBlack,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Tab 4: Income details & Payslip calculation
  Widget _buildIncomeTab(UserProfile? profile, UserProfile? userInfoProfile) {
    final schedules = _getFilteredSchedules(profile);
    final kpis = _getKPIsForSelectedMonth(profile);

    double totalBonus = kpis.fold(0.0, (sum, k) => sum + (k.salaryBonus ?? 0));
    double totalAdvance = kpis.fold(
      0.0,
      (sum, k) => sum + (k.salaryAdvance ?? 0),
    );

    final totalDays = schedules.fold<num>(
      0,
      (sum, s) => sum + (s.isHoliday ?? 0),
    );
    final workingDays = schedules.fold<num>(
      0,
      (sum, s) => sum + (s.workingDay ?? 0),
    );

    final basicSalaryMonthly =
        int.tryParse(
          userInfoProfile?.basicSalary ?? profile?.basicSalary ?? '0',
        ) ??
        0;
    final bhxhAmount =
        double.tryParse(userInfoProfile?.bhxh ?? profile?.bhxh ?? '0') ?? 0;

    final salaryPerDay = totalDays > 0 ? basicSalaryMonthly / totalDays : 0.0;
    final salaryPerHour = salaryPerDay / 8;

    final lateDaysCount = schedules
        .where((s) => (s.lateMinutes ?? 0) > 0)
        .length;
    final latePenalty = (lateDaysCount * 20000).toDouble();

    final homeOvertimeHours = schedules.fold<num>(
      0,
      (sum, s) => sum + (s.overtimeHours ?? 0),
    );
    final companyOvertimeHours = schedules.fold<num>(
      0,
      (sum, s) => sum + (s.companyOvertimeHours ?? 0),
    );
    final totalOvertimeHours = homeOvertimeHours + companyOvertimeHours;
    final overtimePayment = totalOvertimeHours * salaryPerHour;

    double calculatedBasicSalary;
    if (totalDays > 0) {
      if (workingDays > totalDays) {
        final normalDaysSalary = basicSalaryMonthly.toDouble();
        final overtimeDays = workingDays - totalDays;
        final overtimeDaysSalary = overtimeDays * salaryPerDay * 2;
        calculatedBasicSalary = normalDaysSalary + overtimeDaysSalary;
      } else {
        calculatedBasicSalary = salaryPerDay * workingDays;
      }
    } else {
      calculatedBasicSalary = basicSalaryMonthly.toDouble();
    }

    final allowance =
        double.tryParse(
          userInfoProfile?.totalIncome ?? profile?.totalIncome ?? '0',
        ) ??
        0;

    final netSalary =
        calculatedBasicSalary +
        totalBonus +
        allowance -
        bhxhAmount -
        totalAdvance +
        overtimePayment -
        latePenalty;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Payroll Breakdown Card
          Card(
            elevation: 0.5,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.shade100),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.receipt_long_outlined,
                        color: ColorUtil.bangladeshGreen,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Phiếu lương chi tiết',
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: ColorUtil.raisinBlack,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  _buildPayrollRow(
                    'Lương cơ bản',
                    _formatCurrency(basicSalaryMonthly),
                    subtitle:
                        '1 ngày công: ${_formatCurrency(salaryPerDay.round())}',
                  ),
                  _buildPayrollRow(
                    'Lương ngày công thực tế',
                    _formatCurrency(calculatedBasicSalary.round()),
                    subtitle: 'Làm việc: $workingDays/$totalDays ngày',
                  ),
                  if (totalOvertimeHours > 0)
                    _buildPayrollRow(
                      'Lương tăng ca',
                      _formatCurrency(overtimePayment.round()),
                      subtitle: 'Số giờ tăng ca: ${totalOvertimeHours}h',
                    ),
                  if (totalBonus > 0)
                    _buildPayrollRow(
                      'Thưởng KPI',
                      _formatCurrency(totalBonus.round()),
                      color: Colors.green.shade600,
                    ),
                  if (allowance > 0)
                    _buildPayrollRow(
                      'Phụ cấp khác',
                      _formatCurrency(allowance.round()),
                    ),
                  if (latePenalty > 0)
                    _buildPayrollRow(
                      'Khấu trừ đi muộn',
                      '- ${_formatCurrency(latePenalty.round())}',
                      color: Colors.red.shade600,
                      subtitle: 'Vi phạm: $lateDaysCount lần',
                    ),
                  if (bhxhAmount > 0)
                    _buildPayrollRow(
                      'Khấu trừ BHXH',
                      '- ${_formatCurrency(bhxhAmount.round())}',
                      color: Colors.red.shade600,
                    ),
                  if (totalAdvance > 0)
                    _buildPayrollRow(
                      'Tạm ứng lương',
                      '- ${_formatCurrency(totalAdvance.round())}',
                      color: Colors.orange.shade600,
                    ),
                  const Divider(height: 24, thickness: 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Thực nhận',
                          style: GoogleFonts.roboto(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: ColorUtil.raisinBlack,
                          ),
                        ),
                        Text(
                          _formatCurrency(netSalary.round()),
                          style: GoogleFonts.roboto(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: ColorUtil.bangladeshGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayrollRow(
    String label,
    String value, {
    Color? color,
    String? subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: ColorUtil.raisinBlack,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color ?? ColorUtil.raisinBlack,
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.roboto(
                fontSize: 11,
                color: ColorUtil.graniteGray,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
