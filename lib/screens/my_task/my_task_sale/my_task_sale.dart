import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socbay/blocs/task/task_screen_event.dart';
import 'package:socbay/blocs/task/task_screen_sale_bloc.dart';
import 'package:socbay/blocs/task/task_screen_state.dart';
import 'package:socbay/constants/constants.dart';
import 'package:socbay/data/model/task_model.dart';
import 'package:socbay/data/model/user_model.dart';
import 'package:socbay/routes.dart';
import 'package:socbay/screens/staff/technique/technique_screen.dart';
import 'package:socbay/utils/color_util.dart';
import 'package:socbay/utils/context_extension.dart';
import 'package:socbay/utils/scroll_util.dart';
import 'package:socbay/widgets/indicator_loadmore.dart';
import 'package:socbay/widgets/loading_indicator.dart';
import 'package:socbay/widgets/text_field_default.dart';
import 'package:url_launcher/url_launcher.dart';

class MyTaskTabSale extends StatefulWidget {
  const MyTaskTabSale({super.key});

  @override
  State<MyTaskTabSale> createState() => _MyTaskTabState();
}

class _MyTaskTabState extends State<MyTaskTabSale> {
  late TaskScreenSaleBloc _bloc;
  late ScrollController _scrollController;

  late TextEditingController _feedbackController;
  late TextEditingController _searchController;
  String _searchQuery = '';
  String? _selectedStatusFilter;

  static const _statusFilters = [
    _StatusFilterOption(label: 'Tất cả'),
    _StatusFilterOption(label: 'Chưa giao', value: '1'),
    _StatusFilterOption(label: 'Đã giao', value: '5'),
    _StatusFilterOption(label: 'Đang thực hiện', value: '2'),
    _StatusFilterOption(label: 'Hoàn thành', value: '3'),
    _StatusFilterOption(label: 'Hủy', value: '4'),
  ];

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  void _onSearch() {
    setState(() {
      _searchQuery = _searchController.text.trim();
    });
    _bloc.add(
      StaffTaskScreenGetTaskByDayEvent(
        isRefresh: true,
        status: _selectedStatusFilter,
        query: _searchQuery,
      ),
    );
  }

  void _onClearSearch() {
    setState(() {
      _searchQuery = '';
      _searchController.clear();
    });
    _bloc.add(
      StaffTaskScreenGetTaskByDayEvent(
        isRefresh: true,
        status: _selectedStatusFilter,
        query: '',
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _bloc = BlocProvider.of(context);
    _bloc.add(
      StaffTaskScreenGetTaskByDayEvent(
        isRefresh: true,
        status: _selectedStatusFilter,
        query: _searchQuery,
      ),
    );
    _scrollController = ScrollController();
    _feedbackController = TextEditingController();
    _searchController = TextEditingController();
    _scrollController.addListener(() {
      scrollPaginationListener(
        scrollController: _scrollController,
        condition: !_bloc.isLoading && _bloc.hasMoreTaskByday,
        paginationFunction: () {
          _bloc.add(
            StaffTaskScreenGetTaskByDayEvent(
              isRefresh: false,
              status: _selectedStatusFilter,
              query: _searchQuery,
            ),
          );
        },
      );
    });

    if (selectedDate != null) {
      setState(() {});
    } else {
      setState(() {});
    }

    if (selectedTime != null) {
      setState(() {});
    } else {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _feedbackController.dispose();
    _searchController.dispose();
    _bloc.listTaskModel.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TaskScreenSaleBloc, TaskScreenState>(
      builder: _builder,
      listener: _listener,
    );
  }

  void _listener(BuildContext context, state) {
    if (state is BookingDeleteSuccessState) {
      _bloc.add(
        StaffTaskScreenGetTaskByDayEvent(
          isRefresh: true,
          status: _selectedStatusFilter,
          query: _searchQuery,
        ),
      );
      _bloc.add(
        StaffTaskScreenGetTaskAssigedEvent(
          isRefresh: true,
          page: 0,
          status: _bloc.selectedTaskAssignedStatus,
          query: _bloc.selectedTaskAssignedQuery,
        ),
      );
      _feedbackController.clear();
    }
    if (state is BookingDeleteErrorState) {
      context.showSnackBar("Hủy thất bại!");
    }
    if (state is BookingUpdateSuccessState) {
      context.showSnackBar("Gán KTV thành công!");
      _bloc.add(
        StaffTaskScreenGetTaskByDayEvent(
          isRefresh: true,
          status: _selectedStatusFilter,
          query: _searchQuery,
        ),
      );
      _bloc.add(
        StaffTaskScreenGetTaskAssigedEvent(
          isRefresh: true,
          page: 0,
          status: _bloc.selectedTaskAssignedStatus,
          query: _bloc.selectedTaskAssignedQuery,
        ),
      );
    }
    if (state is BookingUpdateErrorState) {
      context.showSnackBar("Gán KTV thất bại!");
    }
    if (state is MyTaskScreenInitialState) {
      setState(() {});
    }
  }

  List<TaskModel> get _tasks => _bloc.staffListTaskBydayModel;

  Widget _builder(BuildContext context, state) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _onSearch(),
                  decoration: const InputDecoration(
                    labelText: "Tìm Kiếm",
                    hintText: "SĐT, tên, địa chỉ khách hàng...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25.0)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 5),
              ElevatedButton(
                onPressed: _onSearch,
                child: const Text('Search'),
              ),
              const SizedBox(width: 5),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: _onClearSearch,
                child: const Text('All', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
        _buildStatusFilterBar(),
        Expanded(
          child: LoadingIndicator(
            isLoading: _bloc.isLoading,
            child: RefreshIndicator(
              onRefresh: () async {
                _bloc.add(
                  StaffTaskScreenGetTaskByDayEvent(
                    isRefresh: true,
                    status: _selectedStatusFilter,
                    query: _searchQuery,
                  ),
                );
              },
              child: _tasks.isEmpty && !_bloc.isLoading
                  ? const CustomScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverFillRemaining(
                          child: Center(child: Text("Chưa có công việc")),
                        ),
                      ],
                    )
                  : ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      controller: _scrollController,
                      itemBuilder: _itemBuilder,
                      itemCount: _tasks.length,
                      padding: const EdgeInsets.symmetric(
                        horizontal: paddingHorizontal,
                        vertical: paddingVertical,
                      ),
                      separatorBuilder: (BuildContext context, int index) {
                        return const Divider(
                          thickness: 1,
                          color: ColorUtil.bangladeshGreen,
                        );
                      },
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _itemBuilder(BuildContext context, int index) {
    if (index >= _tasks.length) {
      return const IndicatorLoadMore();
    }
    TaskModel taskModel = _tasks[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            _detailTask(taskModel);
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.confirmation_number_outlined,
                            size: 20,
                            color: ColorUtil.bangladeshGreen,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Mã DV: ${taskModel.id}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: ColorUtil.bangladeshGreen,
                                fontSize: 16,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusBadge(taskModel.getStatus()),
                  ],
                ),
                const Divider(
                  height: 24,
                  thickness: 1,
                  color: Color(0xFFEEEEEE),
                ),

                _buildInfoRow(
                  Icons.access_time,
                  'Thời gian:',
                  _formatDatetime(taskModel.timeStart),
                  valueColor: Colors.red,
                  isBoldValue: true,
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.person_outline,
                  'Khách hàng:',
                  taskModel.customer?.username ?? '',
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.phone_outlined,
                  'SĐT:',
                  taskModel.customer?.phone ?? '',
                  onTap:
                      (taskModel.customer?.phone != null &&
                          taskModel.customer!.phone!.isNotEmpty)
                      ? () async {
                          final Uri telUri = Uri.parse(
                            'tel:${taskModel.customer!.phone}',
                          );
                          if (await canLaunchUrl(telUri)) {
                            await launchUrl(telUri);
                          }
                        }
                      : null,
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.location_on_outlined,
                  'Địa chỉ:',
                  taskModel.customer?.address ?? '',
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.work_outline,
                  'Công việc:',
                  taskModel.name ?? '',
                ),
                if (taskModel.des != null && taskModel.des!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.description_outlined,
                    'Nội dung:',
                    taskModel.des!,
                  ),
                ],
                if (taskModel.noti != null && taskModel.noti!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.notifications_none,
                    'Thông báo:',
                    taskModel.noti!,
                  ),
                ],

                if (_canShowActions(taskModel)) ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (_canAssignOrCancel(taskModel) &&
                          (taskModel.userId == null ||
                              taskModel.userId!.isEmpty ||
                              taskModel.userId == "0") &&
                          taskModel.staff?.id == null) ...[
                        _buildActionButton(
                          icon: Icons.person_add_alt_1_outlined,
                          text: 'Gán KTV',
                          color: ColorUtil.bangladeshGreen,
                          onTap: () => _onAssignTechnician(taskModel),
                        ),
                        const SizedBox(width: 12),
                      ],
                      _buildActionButton(
                        icon: Icons.edit_outlined,
                        text: 'Sửa',
                        color: ColorUtil.bangladeshGreen,
                        onTap: () => _editBooking(taskModel),
                        isOutlined: true,
                      ),
                      if (_canAssignOrCancel(taskModel)) ...[
                        const SizedBox(width: 12),
                        _buildActionButton(
                          icon: Icons.cancel_outlined,
                          text: 'Huỷ',
                          color: Colors.red,
                          onTap: () => _cancelTask(taskModel),
                          isOutlined: true,
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _canShowActions(TaskModel taskModel) {
    return ['1', '2', '3', '4', '5'].contains(taskModel.status);
  }

  bool _canAssignOrCancel(TaskModel taskModel) {
    return ['1', '2', '5'].contains(taskModel.status);
  }

  Widget _buildStatusFilterBar() {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: _statusFilters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final option = _statusFilters[index];
          final isSelected = option.value == _selectedStatusFilter;
          return ChoiceChip(
            label: Text(option.label),
            selected: isSelected,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : ColorUtil.bangladeshGreen,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            selectedColor: ColorUtil.bangladeshGreen,
            backgroundColor: Colors.white,
            side: BorderSide(
              color: isSelected
                  ? ColorUtil.bangladeshGreen
                  : ColorUtil.bangladeshGreen.withValues(alpha: 0.35),
            ),
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            onSelected: (_) {
              setState(() {
                _selectedStatusFilter = option.value;
              });
              _bloc.add(
                StaffTaskScreenGetTaskByDayEvent(
                  isRefresh: true,
                  status: _selectedStatusFilter,
                  query: _searchQuery,
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _onAssignTechnician(TaskModel taskModel) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => const TechniqueScreen(initialTabIndex: 1),
          ),
        )
        .then((value) {
          if (value != null) {
            Map<String, dynamic> result = value as Map<String, dynamic>;
            UserModel? selectedStaff = result['favouriteStaff'] as UserModel?;
            if (selectedStaff != null) {
              _bloc.add(
                StaffTaskScreenAssignTechnicianEvent(
                  taskId: taskModel.id!,
                  staffId: selectedStaff.id!,
                  taskModel: taskModel,
                ),
              );
            }
          }
        });
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: ColorUtil.bangladeshGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: const TextStyle(
          color: ColorUtil.bangladeshGreen,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
    bool isBoldValue = false,
    VoidCallback? onTap,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        SizedBox(
          width: 85,
          child: Text(
            label,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: onTap,
            child: Text(
              value,
              style: TextStyle(
                color: onTap != null
                    ? (valueColor ?? Colors.blue)
                    : (valueColor ?? Colors.black87),
                fontSize: 14,
                fontWeight: isBoldValue ? FontWeight.bold : FontWeight.normal,
                decoration: onTap != null ? TextDecoration.underline : null,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String text,
    required Color color,
    required VoidCallback onTap,
    bool isOutlined = false,
  }) {
    if (isOutlined) {
      return OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18, color: color),
        label: Text(
          text,
          style: TextStyle(color: color, fontWeight: FontWeight.w600),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          minimumSize: const Size(0, 36),
        ),
      );
    }
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18, color: Colors.white),
      label: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 0,
        minimumSize: const Size(0, 36),
      ),
    );
  }

  void _detailTask(TaskModel taskModel) {
    Navigator.pushNamed(
      context,
      Routes.detailBookingScreen,
      arguments: {'id': taskModel.id},
    );
  }

  void _editBooking(TaskModel taskModel) {
    Navigator.pushNamed(
      context,
      Routes.editServiceScreen,
      arguments: {'id': taskModel.id},
    ).then((value) async {
      if (value == null) {
        return;
      } else {
        Map<String, dynamic>? result = value as Map<String, dynamic>?;
        if (result != null) {
          _bloc.add(
            StaffTaskScreenGetTaskByDayEvent(
              isRefresh: true,
              status: _selectedStatusFilter,
              query: _searchQuery,
            ),
          );
          _bloc.add(
            StaffTaskScreenGetTaskAssigedEvent(
              isRefresh: true,
              status: _bloc.selectedTaskAssignedStatus,
              query: _bloc.selectedTaskAssignedQuery,
            ),
          );
        }
      }
    });
  }

  Future<void> _cancelTask(TaskModel taskModel) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Vui lòng cho biết lý do bạn hủy dịch vụ',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: TextFieldDefault(
            controller: _feedbackController,
            maxLines: 5,
            hintText: 'Nhập lý do hủy...',
          ),
          actionsPadding: const EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: 16,
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _feedbackController.clear();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      side: const BorderSide(color: Colors.grey),
                    ),
                    child: const Text(
                      'Hủy',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _bloc.add(
                        BookingDeleteTaskEvent(
                          taskModel.id ?? 0,
                          taskModel.name ?? '',
                          _feedbackController.text,
                        ),
                      );
                      Navigator.pop(context);
                      _feedbackController.clear();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorUtil.bangladeshGreen,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Gửi',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  String _formatDatetime(String? dateTimeString) {
    try {
      if (dateTimeString == null || dateTimeString.isEmpty) return "";
      DateTime getDateTime = DateTime.parse(dateTimeString);
      var output = DateFormat('HH:mm:ss dd/MM/yyyy').format(getDateTime);
      return output.toString();
    } on Exception catch (ex) {
      print("format datetime error: $ex");
      return dateTimeString ?? "";
    }
  }
}

class _StatusFilterOption {
  final String label;
  final String? value;

  const _StatusFilterOption({required this.label, this.value});
}
