import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:socbay/blocs/user_info/notification/notification_screen_bloc.dart';
import 'package:socbay/blocs/user_info/notification/notification_screen_event.dart';
import 'package:socbay/blocs/user_info/notification/notification_screen_state.dart';
import 'package:socbay/config/app_config.dart';
import 'package:socbay/constants/constants.dart';
import 'package:socbay/data/model/notification_response.dart';
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

  @override
  void initState() {
    super.initState();
    _bloc = BlocProvider.of(context);
    _bloc.add(NotificationScreenStartedEvent());
  }

  @override
  void dispose() {
    super.dispose();
    _bloc.close();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NotificationScreenBloc, NotificationScreenState>(
        builder: _builder, listener: _listener);
  }

  void _listener(BuildContext context, NotificationScreenState state) {}

  Widget _builder(BuildContext context, NotificationScreenState state) {
    return Scaffold(
      appBar: MyAppBar(
        title: "Thông báo",
        centerTitle: true,
        isBackNavigation: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: paddingHorizontal,
          vertical: paddingVertical,
        ),
        itemCount: _bloc.notifications.length,
        itemBuilder: _buildItem,
        separatorBuilder: _buildSeparated,
      ),
    );
  }

  Widget _buildSeparated(BuildContext context, int index) {
    return const Divider(
      color: Colors.grey,
      height: 24,
    );
  }

  Widget _buildItem(BuildContext context, int index) {
    final NotificationResponse item = _bloc.notifications[index];
    return ButtonWidget(
      onTap: () {
        Navigator.pushNamed(context, Routes.notificationDetailScreen,
            arguments: item);
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: ImageUtil.loadNetWorkImage(
                url: item.image != null
                    ? '$protocol${AppConfig.instance.values.apiUrl}${item.image}'
                    : "",
                height: 80,
                width: 120),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  item.name ?? "",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: ColorUtil.bangladeshGreen),
                ),
                Html(data: item.shortdes ?? ''),
              ],
            ),
          )
        ],
      ),
    );
  }
}
