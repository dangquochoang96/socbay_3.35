import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socbay/blocs/home/hotline/hotline_screen_event.dart';
import 'package:socbay/blocs/home/hotline/hotline_screen_state.dart';
import 'package:socbay/data/model/user_profile.dart';
import 'package:socbay/utils/image_util.dart';
import 'package:socbay/utils/theme_util.dart';
import 'package:socbay/widgets/loading_indicator.dart';
import 'package:socbay/widgets/my_app_bar.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../blocs/home/hotline/hotline_screen_bloc.dart';
import '../../utils/color_util.dart';
import '../../routes.dart';

class HotlineScreen extends StatefulWidget {
  const HotlineScreen({super.key});

  @override
  State<HotlineScreen> createState() => _HotlineScreenState();
}

class _HotlineScreenState extends State<HotlineScreen> {
  late HotlineScreenBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = BlocProvider.of(context);
    _bloc.add(HotlineScreenStartedEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HotlineScreenBloc, HotlineScreenState>(
        builder: _builder, listener: _listener);
  }

  void _listener(BuildContext context, HotlineScreenState state) {}

  Widget _builder(BuildContext context, HotlineScreenState state) {
    return SafeArea(
        child: Scaffold(
      appBar: MyAppBar(
        title: "Hotline",
        isBackNavigation: true,
        centerTitle: true,
      ),
      body: LoadingIndicator(
        isLoading: _bloc.isLoading,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          itemBuilder: _itemBuilder,
          itemCount: _bloc.users.length,
        ),
      ),
    ));
  }

  Widget _itemBuilder(BuildContext context, int index) {
    final UserProfile item = _bloc.users[index];
    return GestureDetector(
      onTap: () async {
        Navigator.pushNamed(context, Routes.staffInfoScreen, arguments: {
          "id": item.id,
          "name": item.username,
          "staffInfo": item
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: ColorUtil.bangladeshGreen),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: ImageUtil.loadNetWorkImage(
                  url: item.avatar ?? '', height: 50, width: 50),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${item.username}',
                      style: const TextStyle(
                          fontWeight: MyFontWeight.bold,
                          overflow: TextOverflow.ellipsis),
                      maxLines: 1,
                    ),
                    Text('${item.phone}'),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () async {
                final url = "tel:${item.phone}";
                await launchUrl(Uri.parse(url));
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  // color: Colors.red,
                ),
                child: const Icon(Icons.phone, color: Colors.red),
              ),
            )
          ],
        ),
      ),
    );
  }
}
