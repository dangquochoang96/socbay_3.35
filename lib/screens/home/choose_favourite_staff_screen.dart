import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socbay/blocs/home/choose_favourite_staff/choose_favourite_staff_bloc.dart';
import 'package:socbay/blocs/home/choose_favourite_staff/choose_favourite_staff_event.dart';
import 'package:socbay/blocs/home/choose_favourite_staff/choose_favourite_staff_state.dart';

import '../../constants/constants.dart';
import '../../data/model/user_model.dart';
import '../../utils/color_util.dart';
import '../../utils/image_util.dart';
import '../../utils/theme_util.dart';
import '../../widgets/button_widget.dart';
import '../../widgets/my_app_bar.dart';
import '../staff/technique/technique_screen.dart';

class ChooseFavouriteStaffScreen extends StatefulWidget {
  const ChooseFavouriteStaffScreen({super.key});

  @override
  State<ChooseFavouriteStaffScreen> createState() =>
      _ChooseFavouriteStaffScreenState();
}

class _ChooseFavouriteStaffScreenState
    extends State<ChooseFavouriteStaffScreen> {
  late final ChooseFavouriteStaffBloc _bloc;
  late UserModel? userProfile;

  @override
  void initState() {
    _bloc = BlocProvider.of(context);
    _bloc.add(ChooseFavouriteStaffStartedEvent());
    userProfile = _bloc.args['favouriteStaff'] as UserModel?;
    super.initState();
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChooseFavouriteStaffBloc, ChooseFavouriteStaffState>(
      builder: _builder,
      listener: _listener,
    );
  }

  void _listener(BuildContext context, ChooseFavouriteStaffState state) {}

  Widget _builder(BuildContext context, ChooseFavouriteStaffState state) {
    final bool hasItems = _bloc.favouriteStaffs.isNotEmpty;
    return Scaffold(
      appBar: MyAppBar(
        title: "Kỹ thuật viên yêu thích",
        isBackNavigation: true,
        centerTitle: true,
      ),
      body: Visibility(
        replacement: const Center(child: Text("Trống")),
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(
            horizontal: paddingHorizontal,
            vertical: paddingVertical,
          ),
          itemCount: _bloc.favouriteStaffs.length + 1,
          itemBuilder: (BuildContext context, int index) {
            if (hasItems) {
              return _itemBuilder(context, index);
            } else {
              return _itemDefault(context, index);
            }
          },
          separatorBuilder: _buildSeparator,
        ),
      ),
    );
  }

  Widget _buildSeparator(BuildContext context, int index) {
    return const SizedBox(height: 12);
  }

  Widget _itemBuilder(BuildContext context, int index) {
    final UserModel item = _bloc.favouriteStaffs[index];
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ColorUtil.bangladeshGreen),
      ),
      child: ButtonWidget(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          _onChooseFavouriteStaff(item);
        },
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
            IconButton(
              onPressed: () {
                _onChooseFavouriteStaff(item);
              },
              icon: userProfile?.id == item.id
                  ? const Icon(
                      Icons.check_box,
                      color: ColorUtil.bangladeshGreen,
                    )
                  : const Icon(
                      Icons.check_box_outline_blank,
                      color: ColorUtil.bangladeshGreen,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _itemDefault(BuildContext context, int index) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ColorUtil.bangladeshGreen),
        color: ColorUtil.bangladeshGreen,
      ),
      child: ButtonWidget(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const TechniqueScreen(initialTabIndex: 1),
            ),
          );
          _onChooseFavouriteStaff(null);
        },
        child: const Center(
          child: Text(
            "KHÁC",
            style: TextStyle(
              fontWeight: MyFontWeight.bold,
              color: ColorUtil.white,
            ),
          ),
        ),
      ),
    );
  }

  void _onChooseFavouriteStaff(UserModel? userProfile) {
    if (this.userProfile?.id != userProfile?.id) {
      Navigator.pop(context, {"favouriteStaff": userProfile});
    }
  }
}
