import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socbay/data/model/user_profile.dart';
import 'package:socbay/widgets/my_app_bar.dart';
import '../../../blocs/technique/technique_screen_bloc.dart';
import '../../../blocs/technique/technique_screen_event.dart';
import '../../../blocs/technique/technique_screen_state.dart';
import '../../../utils/color_util.dart';
import '../../../utils/image_util.dart';
import '../../../utils/theme_util.dart';
import '../../../widgets/button_widget.dart';

class TechniqueScreen extends StatefulWidget {
  const TechniqueScreen(
      {super.key, required int initialTabIndex, UserProfile? favoriteStaff});

  @override
  State<TechniqueScreen> createState() => _TechniqueScreenState();
}

class _TechniqueScreenState extends State<TechniqueScreen>
    with TickerProviderStateMixin {
  late TechniqueScreenBloc _bloc;
  late TabController _tabController;
  int index = 0;
  bool isLoading = false;
  late UserProfile userProfile;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TechniqueScreenBloc, TechniqueScreenState>(
        builder: _builder, listener: _listener);
  }

  @override
  void initState() {
    super.initState();
    _bloc = BlocProvider.of(context);
    userProfile = _bloc.args['favouriteStaff'] as UserProfile? ?? UserProfile();
    _bloc.add(TechniqueScreenStartedFaEvent());
    _bloc.add(TechniqueScreenStartedEvent());
    _tabController = TabController(
      length: 2,
      initialIndex: 0,
      vsync: this,
    );
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          index = _tabController.index;
        });
      }
    });

    _bloc.users = List.from(_bloc.users);
  }

  void _listener(BuildContext context, state) {}

  Widget _builder(BuildContext context, TechniqueScreenState state) {
    return Scaffold(
      appBar: MyAppBar(
        title: "Lựa chọn kỹ thuật viên",
        isBackNavigation: false,
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorColor: ColorUtil.bangladeshGreen,
            tabs: [
              _buildTab('Kỹ thuật viên yêu thích'),
              _buildTab('Kỹ thuật viên khác'),
            ],
          ),
          Expanded(
            child: IndexedStack(
              index: _tabController.index,
              children: [
                _buildMyTask(),
                _buildTaskAvailable(),
              ],
            ),
          )
        ],
      ),
    );
  }

  Tab _buildTab(text) {
    return Tab(
      height: 36,
      child: Text(
        text,
        style: const TextStyle(color: ColorUtil.bangladeshGreen, fontSize: 20),
      ),
    );
  }

  Widget _buildMyTask() {
    final usersToShow = index == 0 ? _bloc.favouriteStaffs : _bloc.users;

    return ListView.separated(
        itemBuilder: _buildItemServiceHistory,
        separatorBuilder: separatorBuilder,
        itemCount: usersToShow.length);
  }

  Widget _buildTaskAvailable() {
    final usersToShow = index == 0 ? _bloc.favouriteStaffs : _bloc.users;

    return ListView.separated(
        itemBuilder: _buildItemMachineInUse,
        separatorBuilder: separatorBuilder,
        itemCount: usersToShow.length);
  }

  Widget separatorBuilder(BuildContext context, int index) {
    return Container(
        decoration: const BoxDecoration(
      border: Border(
        bottom: BorderSide(width: 1.0, color: Colors.black26),
      ),
    ));
  }

  Widget _buildItemServiceHistory(BuildContext context, int index) {
    if (_bloc.favouriteStaffs.isEmpty) {
      return const Center(child: Text("No favorite staffs yet"));
    }
    final UserProfile item = _bloc.favouriteStaffs[0];
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
                  url: item.avatar ?? '', height: 50, width: 50),
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
              icon: userProfile.id == item.id
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

  Widget _buildItemMachineInUse(BuildContext context, int index) {
    final UserProfile taskKT = _bloc.users[index];
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ColorUtil.bangladeshGreen),
      ),
      child: ButtonWidget(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          _onChooseFavouriteStaff(taskKT);
        },
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: ImageUtil.loadNetWorkImage(
                  url: taskKT.avatar ?? '', height: 50, width: 50),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${taskKT.username}",
                    style: const TextStyle(fontWeight: MyFontWeight.bold),
                  ),
                  Text("${taskKT.phone}"),
                ],
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              onPressed: () {
                _onChooseFavouriteStaff(taskKT);
              },
              icon: userProfile.id == taskKT.id
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

  void _onChooseFavouriteStaff(UserProfile? userProfile) {
    if (this.userProfile.id != userProfile?.id) {
      Navigator.pop(context, {
        "initialUserProfile": userProfile,
        "favouriteStaff": userProfile,
      });
    }
  }
}
