import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_app/restart_app.dart';
import 'package:socbay/application.dart';
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

class UserModelScreen extends StatefulWidget {
  const UserModelScreen({super.key});

  @override
  State<UserModelScreen> createState() => _UserModelScreenState();
}

class _UserModelScreenState extends State<UserModelScreen> {
  late UserScreenBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = BlocProvider.of(context);
    _bloc.add(UserScreenStartedEvent());
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
    final user = _bloc.user ?? App.instance.userApp;
    final isCustomer = App.instance.userApp?.isUserCustomer() == true;
    final isSale = App.instance.userApp?.isUserSale() == true;

    return LoadingIndicator(
      isLoading: _bloc.isLoading,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F8FA),
        appBar: _buildAppBar(),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 36),
          children: [
            _buildProfileHeader(user, isCustomer),
            const SizedBox(height: 16),
            _buildMenuCard(
              children: [
                _buildMenuItem(
                  title: "Thông tin tài khoản",
                  icon: Icons.person_outline_rounded,
                  onTap: () {
                    Navigator.pushNamed(context, Routes.accountInfoScreen).then(
                      (value) {
                        _bloc.user = App.instance.userApp;
                        setState(() {});
                      },
                    );
                  },
                ),
                if (isCustomer) ...[
                  _buildMenuDivider(),
                  _buildPointMenuItem('${_bloc.user?.point ?? 0}'),
                  _buildMenuDivider(),
                  _buildMenuItem(
                    title: "Kĩ thuật viên yêu thích",
                    icon: Icons.favorite_outline_rounded,
                    onTap: () {
                      Navigator.pushNamed(context, Routes.favouriteStaff);
                    },
                  ),
                ],
                if (isSale) ...[
                  _buildMenuDivider(),
                  _buildMenuItem(
                    title: "Thông báo",
                    icon: Icons.notifications_none_rounded,
                    onTap: () {
                      Navigator.pushNamed(context, Routes.notificationScreen);
                    },
                  ),
                  _buildMenuDivider(),
                  _buildMenuItem(
                    title: "Kĩ thuật viên yêu thích",
                    icon: Icons.favorite_outline_rounded,
                    onTap: () {
                      Navigator.pushNamed(context, Routes.favouriteStaff);
                    },
                  ),
                ],
                if (!isCustomer) ...[
                  _buildMenuDivider(),
                  _buildMenuItem(
                    title: "Chấm công & KPI",
                    icon: Icons.analytics_outlined,
                    onTap: () {
                      Navigator.pushNamed(context, Routes.hrManagementSummary);
                    },
                  ),
                ],
                _buildMenuDivider(),
                _buildMenuItem(
                  title: "Đổi mật khẩu",
                  icon: Icons.lock_reset_rounded,
                  onTap: () {
                    Navigator.pushNamed(context, Routes.changePasswordScreen);
                  },
                ),
                if (isCustomer) ...[
                  _buildMenuDivider(),
                  _buildMenuItem(
                    title: "Chia sẻ",
                    icon: Icons.share_outlined,
                    onTap: () {
                      shareText(content: Constants.linkAppUrl);
                    },
                  ),
                ],
              ],
            ),
            if (!isCustomer) ...[
              const SizedBox(height: 14),
              _buildMenuCard(
                children: [
                  _buildMenuItem(
                    title: "Chính sách quyền riêng tư",
                    icon: Icons.policy_outlined,
                    onTap: _launchURL,
                  ),
                  _buildMenuDivider(),
                  _buildMenuItem(
                    title: "Xóa tài khoản",
                    icon: Icons.delete_outline_rounded,
                    iconColor: const Color(0xFFD97706),
                    iconBgColor: const Color(0xFFFEF3C7),
                    onTap: _showDeleteAccountDialog,
                  ),
                ],
              ),
            ],
            const SizedBox(height: 14),
            _buildLogoutCard(),
            const SizedBox(height: 20),
            const HotlineWidget(),
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

  MyAppBar _buildAppBar() {
    return MyAppBar(
      isBackNavigation: true,
      title: "Thông tin cá nhân",
      centerTitle: true,
    );
  }

  Widget _buildProfileHeader(dynamic user, bool isCustomer) {
    final String displayName = (user?.username?.toString().isNotEmpty == true)
        ? user.username.toString()
        : 'Người dùng';
    final String phone = user?.phone?.toString() ?? '';
    final String? avatarPath = user?.avatar?.toString();
    final String avatarUrl = (avatarPath != null && avatarPath.isNotEmpty)
        ? "$protocol${AppConfig.instance.values.apiUrl}$avatarPath"
        : '';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColorUtil.bangladeshGreen,
            ColorUtil.bangladeshGreen.withValues(alpha: 0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: ColorUtil.bangladeshGreen.withValues(alpha: 0.22),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.85),
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: ImageUtil.loadNetWorkImage(
                url: avatarUrl,
                width: 72,
                height: 72,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (phone.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.phone_outlined,
                        size: 14,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          phone,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.92),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (isCustomer) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Điểm tích lũy: ${user?.point ?? 0}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, Routes.accountInfoScreen).then((
                value,
              ) {
                _bloc.user = App.instance.userApp;
                setState(() {});
              });
            },
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.edit_outlined,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildMenuDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 62,
      endIndent: 16,
      color: Colors.grey.shade100,
    );
  }

  Widget _buildMenuItem({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    Color? iconColor,
    Color? iconBgColor,
    Color? textColor,
  }) {
    final effectiveIconColor = iconColor ?? ColorUtil.bangladeshGreen;
    final effectiveIconBgColor =
        iconBgColor ?? ColorUtil.bangladeshGreen.withValues(alpha: 0.1);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: effectiveIconBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: effectiveIconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: textColor ?? ColorUtil.raisinBlack,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 15,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPointMenuItem(String point) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.stars_rounded,
              color: Color(0xFFD97706),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "Tích điểm",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: ColorUtil.raisinBlack,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: ColorUtil.bangladeshGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$point điểm',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: ColorUtil.bangladeshGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFEE2E2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _onLogout,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: Color(0xFFDC2626),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    "Đăng xuất",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFDC2626),
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 15,
                  color: Color(0xFFEF4444),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          scrollable: true,
          title: const Text(
            'Xóa tài khoản',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
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
