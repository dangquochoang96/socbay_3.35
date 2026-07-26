import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socbay/blocs/home/hotline/hotline_screen_event.dart';
import 'package:socbay/blocs/home/hotline/hotline_screen_state.dart';
import 'package:socbay/data/model/user_model.dart';
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
  late TextEditingController _searchController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _bloc = BlocProvider.of(context);
    _bloc.add(HotlineScreenStartedEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HotlineScreenBloc, HotlineScreenState>(
      builder: _builder,
      listener: _listener,
    );
  }

  void _listener(BuildContext context, HotlineScreenState state) {}

  String _getRoleName(UserModel user) {
    if (user.isUserSale()) return "Kinh doanh";
    if (user.isUserRole()) return "Kỹ thuật viên";
    return "Nhân viên";
  }

  Widget _builder(BuildContext context, HotlineScreenState state) {
    final filteredUsers = _bloc.users.where((user) {
      final name = (user.username ?? '').toLowerCase();
      final phone = (user.phone ?? '').toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || phone.contains(query);
    }).toList();

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: MyAppBar(
          title: "Danh sách KTV",
          isBackNavigation: true,
          centerTitle: true,
        ),
        body: LoadingIndicator(
          isLoading: _bloc.isLoading,
          child: Column(
            children: [
              // Modern Search Bar
              Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                color: Colors.white,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200, width: 1),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                    style: const TextStyle(
                      fontSize: 14,
                      color: ColorUtil.raisinBlack,
                    ),
                    decoration: InputDecoration(
                      hintText: "Tìm kiếm nhân viên...",
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade400,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: Colors.grey.shade500,
                        size: 20,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                              child: Icon(
                                Icons.cancel_rounded,
                                color: Colors.grey.shade400,
                                size: 20,
                              ),
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),

              // User List / Search Results
              Expanded(
                child: filteredUsers.isEmpty
                    ? (_bloc.isLoading ? const SizedBox() : _buildEmptyState())
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        itemCount: filteredUsers.length,
                        itemBuilder: (context, index) {
                          return _buildUserCard(context, filteredUsers[index]);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, UserModel item) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100, width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.pushNamed(
                context,
                Routes.staffInfoScreen,
                arguments: {
                  "id": item.id,
                  "name": item.username,
                  "staffInfo": item,
                },
              );
            },
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Left Accent Indicator
                  Container(width: 5, color: ColorUtil.bangladeshGreen),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 4,
                      ),
                      child: Row(
                        children: [
                          // Beautiful Avatar Ring
                          _buildAvatar(item),
                          const SizedBox(width: 14),

                          // Technical Staff Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.username ?? '',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: MyFontWeight.bold,
                                          color: ColorUtil.raisinBlack,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        maxLines: 1,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: ColorUtil.bangladeshGreen
                                            .withValues(alpha: 0.08),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        _getRoleName(item),
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: MyFontWeight.medium,
                                          color: ColorUtil.bangladeshGreen,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.phone_iphone_rounded,
                                      size: 14,
                                      color: Colors.grey.shade400,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      item.phone ?? "N/A",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                                if (item.point != null && item.point! > 0) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: ColorUtil.brightYellow.withValues(
                                        alpha: 0.08,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.workspace_premium_rounded,
                                          size: 14,
                                          color: ColorUtil.brightYellow,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Điểm tích lũy: ${item.point}',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: MyFontWeight.semiBold,
                                            color: Color(0xffcc7a00),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Call Action Button
                          GestureDetector(
                            onTap: () async {
                              final url = "tel:${item.phone}";
                              await launchUrl(Uri.parse(url));
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.08),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.phone_in_talk_rounded,
                                color: Colors.green,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(UserModel item) {
    final avatarUrl = item.companyAvatar ?? '';
    if (avatarUrl.isEmpty) {
      final initial = (item.username != null && item.username!.isNotEmpty)
          ? item.username!.substring(0, 1).toUpperCase()
          : 'K';
      return Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              ColorUtil.bangladeshGreen.withValues(alpha: 0.6),
              ColorUtil.bangladeshGreen,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          initial,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: ColorUtil.bangladeshGreen.withValues(alpha: 0.15),
          width: 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: ImageUtil.loadNetWorkImage(
          url: ImageUtil.getUrlFromPath(avatarUrl),
          height: 52,
          width: 52,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_search_rounded,
                size: 64,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Không tìm thấy nhân viên',
              style: TextStyle(
                fontSize: 16,
                fontWeight: MyFontWeight.bold,
                color: ColorUtil.raisinBlack,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Thử tìm kiếm bằng tên hoặc số điện thoại khác xem nhé.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}
