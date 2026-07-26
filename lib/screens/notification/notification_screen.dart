import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
import 'package:socbay/blocs/user_info/notification/notification_screen_bloc.dart';
import 'package:socbay/blocs/user_info/notification/notification_screen_event.dart';
import 'package:socbay/blocs/user_info/notification/notification_screen_state.dart';
import 'package:socbay/config/app_config.dart';
import 'package:socbay/constants/constants.dart';
import 'package:socbay/data/model/notification_response.dart';
import 'package:socbay/data/model/order_detail_model.dart';
import 'package:socbay/routes.dart';
import 'package:socbay/utils/color_util.dart';
import 'package:socbay/utils/image_util.dart';
import 'package:socbay/widgets/button_widget.dart';
import 'package:socbay/widgets/my_app_bar.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late NotificationScreenBloc _bloc;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _bloc = BlocProvider.of(context);
    _bloc.add(NotificationScreenStartedEvent());
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _bloc.add(NotificationScreenLoadMoreEvent());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
    _bloc.close();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NotificationScreenBloc, NotificationScreenState>(
      builder: _builder,
      listener: _listener,
    );
  }

  void _listener(BuildContext context, NotificationScreenState state) {}

  Widget _builder(BuildContext context, NotificationScreenState state) {
    return Scaffold(
      appBar: MyAppBar(
        title: "Thông báo",
        centerTitle: true,
        isBackNavigation: true,
      ),
      body: _bloc.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                _bloc.add(NotificationScreenStartedEvent());
              },
              child: _bloc.notifications.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 200),
                        Center(
                          child: Text(
                            "Chưa có thông báo nào",
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: paddingHorizontal,
                        vertical: paddingVertical,
                      ),
                      itemCount:
                          _bloc.notifications.length +
                          (_bloc.isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _bloc.notifications.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            child: Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                              ),
                            ),
                          );
                        }
                        return _buildItem(context, index);
                      },
                      separatorBuilder: _buildSeparated,
                    ),
            ),
    );
  }

  Widget _buildSeparated(BuildContext context, int index) {
    return const Divider(color: Colors.grey, height: 24);
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    try {
      return DateFormat('HH:mm dd/MM/yyyy').format(dateTime);
    } catch (_) {
      return '';
    }
  }

  Widget _buildItem(BuildContext context, int index) {
    final NotificationResponse item = _bloc.notifications[index];
    final bool hasImage = item.image != null && item.image!.trim().isNotEmpty;
    final String imageUrl = hasImage
        ? (item.image!.startsWith('http')
              ? item.image!
              : '$protocol${AppConfig.instance.values.apiUrl}${item.image}')
        : '';
    final String titleText = item.title ?? item.name ?? '';
    final String messageText = item.message ?? item.shortdes ?? '';
    final String dateText = _formatDateTime(item.createdAt);

    return ButtonWidget(
      onTap: () {
        if (item.actionType == 'tasks' &&
            item.actionValue != null &&
            item.actionValue!.isNotEmpty) {
          Navigator.pushNamed(
            context,
            Routes.detailBookingScreen,
            arguments: {'id': item.actionValue},
          );
        } else if ((item.actionType == 'rent_tasks' ||
                item.actionType == 'rent-tasks') &&
            item.actionValue != null &&
            item.actionValue!.isNotEmpty) {
          Navigator.pushNamed(
            context,
            Routes.detailRentBookingScreen,
            arguments: {'id': item.actionValue},
          );
        } else if (item.actionType == 'order' &&
            item.actionValue != null &&
            item.actionValue!.isNotEmpty) {
          Navigator.pushNamed(
            context,
            Routes.coreReplacementServiceScreen,
            arguments: {
              'orderDetail': OrderDetailModel(
                id: int.tryParse(item.actionValue!),
              ),
            },
          );
        }
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasImage) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: ImageUtil.loadNetWorkImage(
                url: imageUrl,
                height: 80,
                width: 120,
              ),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  titleText,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: ColorUtil.bangladeshGreen,
                  ),
                ),
                const SizedBox(height: 4),
                if (messageText.contains('<') && messageText.contains('>'))
                  Html(data: messageText)
                else
                  Text(
                    messageText,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                if (dateText.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 13,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        dateText,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
