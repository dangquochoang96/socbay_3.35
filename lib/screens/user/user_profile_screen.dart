import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_app/restart_app.dart';
import 'package:socbay/application.dart';
import 'package:socbay/blocs/task/task_screen_bloc.dart';
import 'package:socbay/blocs/user_info/user_screen_bloc.dart';
import 'package:socbay/blocs/user_info/user_screen_event.dart';
import 'package:socbay/blocs/user_info/user_screen_state.dart';
import 'package:socbay/config/app_config.dart';
import 'package:socbay/constants/constants.dart';
import 'package:socbay/routes.dart';
import 'package:socbay/utils/color_util.dart';
import 'package:socbay/utils/file_util.dart';
import 'package:socbay/utils/image_util.dart';
import 'package:socbay/widgets/button_widget.dart';
import 'package:socbay/widgets/dialog/custom_alert_dialog.dart';
import 'package:socbay/widgets/hotline_widget.dart';
import 'package:socbay/widgets/loading_indicator.dart';
import 'package:socbay/widgets/my_app_bar.dart';
import 'package:url_launcher/url_launcher.dart';

const BorderRadius borderTextField = BorderRadius.all(Radius.circular(13));

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late UserScreenBloc _bloc;
  late TaskScreenBloc _taskScreenBloc;
  // late final ImagePicker _picker;

  @override
  void initState() {
    super.initState();
    _bloc = BlocProvider.of(context);
    _taskScreenBloc = BlocProvider.of(context);

    _bloc.add(UserScreenStartedEvent());
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserScreenBloc, UserScreenState>(
      builder: _builder,
      listener: _listener,
    );
  }

  void _listener(BuildContext context, state) {
    if (state is UserScreenLogoutState) {
      Restart.restartApp(webOrigin: '/');
    }
  }

  Widget _builder(BuildContext context, state) {
    return LoadingIndicator(
      isLoading: _bloc.isLoading,
      child: Scaffold(
        appBar: _buildAppBar(),
        body: ListView(
          children: [
            const SizedBox(height: 15),
            _buildAvatar(),
            const SizedBox(height: 20),
            buildSection("Thông tin tài khoản", Icons.account_circle, () {
              Navigator.pushNamed(context, Routes.accountInfoScreen).then((
                value,
              ) {
                _bloc.user = App.instance.userApp;
                setState(() {});
              });
            }, Colors.grey),
            if (App.instance.userApp?.isUserCustomer() == true) ...[
              buildPointWidget("Tích điểm", '${_bloc.user?.point ?? 0}', () {}),
              buildSection("Kĩ thuật viên yêu thích", Icons.favorite, () {
                Navigator.pushNamed(context, Routes.favouriteStaff);
              }, Colors.grey),
            ],
            if (App.instance.userApp?.isUserSale() == true) ...[
              buildSection("Thông báo", Icons.notifications, () {
                Navigator.pushNamed(context, Routes.notificationScreen);
              }, Colors.grey),
              buildSection("Kĩ thuật viên yêu thích", Icons.favorite, () {
                Navigator.pushNamed(context, Routes.favouriteStaff);
              }, Colors.grey),
            ],
            buildSection("Đổi mật khẩu", Icons.change_circle, () {
              Navigator.pushNamed(context, Routes.changePasswordScreen);
            }, Colors.grey),
            if (App.instance.userApp?.isUserCustomer() == true) ...[
              buildSection("Chia sẻ", Icons.share_outlined, () {
                shareText(content: Constants.linkAppUrl);
              }, Colors.grey),
            ],
            if (App.instance.userApp?.isUserCustomer() != true) ...[
              buildDeleteAcc(),
              buildPolicy(),
            ],
            buildSection("Đăng xuất", Icons.logout, _onLogout, Colors.red),
            const HotlineWidget(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Future<void> _launchURL() async {
    final Uri url = Uri.parse(
      'https://geysereco.com/chinh-sach-bao-mat-thong-tin-khach-hang',
    );
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  Widget _buildAvatar() {
    return Center(
      child: GestureDetector(
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(140),
              child: ImageUtil.loadNetWorkImage(
                url: _bloc.user != null && _bloc.user!.avatar != null
                    ? "$protocol${AppConfig.instance.values.apiUrl}${_bloc.user!.avatar!}"
                    : '',
                width: 160,
                height: 160,
              ),
            ),
          ],
        ),
      ),
    );
  }

  MyAppBar _buildAppBar() {
    return MyAppBar(
      isBackNavigation: true,
      title: "Thông tin cá nhân",
      centerTitle: true,
    );
  }

  Widget buildSection(String title, IconData icon, VoidCallback onTap, color) {
    return Column(
      children: [
        ButtonWidget(
          padding: const EdgeInsets.symmetric(
            horizontal: paddingHorizontal,
            vertical: 12,
          ),
          onTap: onTap,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: TextStyle(fontSize: 15, color: color)),
                  Icon(icon, color: color),
                ],
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: paddingHorizontal),
          child: Divider(color: Colors.grey, height: 0),
        ),
      ],
    );
  }

  Widget buildDeleteAcc() {
    return Column(
      children: [
        ButtonWidget(
          padding: const EdgeInsets.symmetric(
            horizontal: paddingHorizontal,
            vertical: 12,
          ),
          onTap: () {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  scrollable: true,
                  title: const Text(
                    'Xóa tài khoản ',
                    textAlign: TextAlign.center,
                  ),
                  content: const Text(
                    "Tài khoản của bạn sẽ bị xóa sau 15 ngày, bạn có đồng ý xóa tài khoản?",
                  ),
                  actions: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildButtonDialog(
                          isPositive: false,
                          text: 'Hủy',
                          action: () {
                            Navigator.pop(context);
                          },
                        ),
                        const SizedBox(width: 16),
                        _buildButtonDialog(
                          isPositive: true,
                          text: 'Đồng ý',
                          action: () {
                            _bloc.add(UserScreenLogoutEvent());
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ],
                );
              },
            );
          },
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "Xóa tài khoản",
                    style: TextStyle(fontSize: 15, color: Colors.grey),
                  ),
                  Icon(Icons.auto_delete, color: Colors.grey),
                ],
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: paddingHorizontal),
          child: Divider(color: Colors.grey, height: 0),
        ),
      ],
    );
  }

  Widget buildPolicy() {
    return Column(
      children: [
        ButtonWidget(
          padding: const EdgeInsets.symmetric(
            horizontal: paddingHorizontal,
            vertical: 12,
          ),
          onTap: _launchURL,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "Chính sách quyền riêng tư",
                    style: TextStyle(fontSize: 15, color: Colors.grey),
                  ),
                  Icon(Icons.policy, color: Colors.grey),
                ],
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: paddingHorizontal),
          child: Divider(color: Colors.grey, height: 0),
        ),
      ],
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

  Widget buildPointWidget(String title, String point, onTap) {
    return Column(
      children: [
        ButtonWidget(
          padding: const EdgeInsets.symmetric(
            horizontal: paddingHorizontal,
            vertical: 12,
          ),
          onTap: onTap,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 15, color: Colors.grey),
                  ),
                  Text(
                    point,
                    style: const TextStyle(fontSize: 15, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: paddingHorizontal),
          child: Divider(color: Colors.grey, height: 0),
        ),
      ],
    );
  }

  void _onLogout() {
    CustomAlertDialog.show(
      context,
      content: "Đăng xuất?",
      isShowTitle: false,
      leftText: "OK",
      rightText: "Hủy",
      isLeftPositive: true,
      leftAction: () {
        _bloc.add(UserScreenLogoutEvent());
      },
    );
  }
}
