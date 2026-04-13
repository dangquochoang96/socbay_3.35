import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socbay/blocs/user_info/favourite_staff/favourite_staff_event.dart';
import 'package:socbay/blocs/user_info/favourite_staff/favourite_staff_bloc.dart';
import 'package:socbay/constants/constants.dart';
import 'package:socbay/data/model/user_profile.dart';
import 'package:socbay/utils/color_util.dart';
import 'package:socbay/utils/image_util.dart';
import 'package:socbay/utils/theme_util.dart';
import 'package:socbay/widgets/button_widget.dart';
import 'package:socbay/widgets/my_app_bar.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../blocs/user_info/favourite_staff/favourite_staff_state.dart';
import '../../routes.dart';

class FavouriteStaffScreen extends StatefulWidget {
  const FavouriteStaffScreen({Key? key}) : super(key: key);

  @override
  State<FavouriteStaffScreen> createState() => _FavouriteStaffScreenState();
}

class _FavouriteStaffScreenState extends State<FavouriteStaffScreen> {
  late FavouriteStaffBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = BlocProvider.of(context);
    _bloc.add(FavouriteStaffStartedEvent());
  }

  @override
  void dispose() {
    super.dispose();
    _bloc.close();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FavouriteStaffBloc, FavouriteStaffState>(
        builder: _builder, listener: _listener);
  }

  void _listener(BuildContext context, FavouriteStaffState state) {}

  Widget _builder(BuildContext context, FavouriteStaffState state) {
    return Scaffold(
      appBar: MyAppBar(
        title: "Kỹ thuật viên yêu thích",
        isBackNavigation: true,
        centerTitle: true,
      ),
      body: Visibility(
        visible: _bloc.isLoading || _bloc.favouriteStaffs.isNotEmpty,
        replacement: const Center(
          child: Text("Trống"),
        ),
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(
            horizontal: paddingHorizontal,
            vertical: paddingVertical,
          ),
          itemCount: _bloc.favouriteStaffs.length,
          itemBuilder: _itemBuilder,
          separatorBuilder: _buildSeparator,
        ),
      ),
    );
  }

  Widget _buildSeparator(BuildContext context, int index) {
    return const SizedBox(height: 12);
  }


  Widget _itemBuilder(BuildContext context, int index) {
    final UserProfile item = _bloc.favouriteStaffs[index];
    return  Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: ColorUtil.bangladeshGreen),
        ),
        child: ButtonWidget(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          borderRadius: BorderRadius.circular(14),
          onTap: () {  Navigator.pushNamed(context, Routes.staffInfoScreen, arguments: {
            "id": item.id,
            "name": item.username,
            "staffInfo": item
          }); },
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: ImageUtil.loadNetWorkImage(
                  url: item.avatar ?? '',
                  height: 50,
                  width: 50,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${item.username}",
                      style: const TextStyle(fontWeight: MyFontWeight.bold),
                    ),
                    Text("${item.phone}"),
                  ],
                ),
              ),
              const IconButton(
                onPressed: null, // Disable the message button
                icon: Icon(
                  Icons.message,
                  color: ColorUtil.bangladeshGreen,
                ),
              ),
              IconButton(
                onPressed: () async {
                  final url = "tel:${item.phone}";
                  await launchUrl(Uri.parse(url));
                },
                icon: const Icon(
                  Icons.call,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      );
  }
}
