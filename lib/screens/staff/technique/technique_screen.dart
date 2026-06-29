import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socbay/data/model/user_model.dart';
import 'package:socbay/widgets/my_app_bar.dart';
import '../../../blocs/technique/technique_screen_bloc.dart';
import '../../../blocs/technique/technique_screen_event.dart';
import '../../../blocs/technique/technique_screen_state.dart';
import '../../../utils/color_util.dart';
import '../../../utils/image_util.dart';
import '../../../utils/theme_util.dart';

class TechniqueScreen extends StatefulWidget {
  const TechniqueScreen({
    super.key,
    required int initialTabIndex,
    UserModel? favoriteStaff,
  });

  @override
  State<TechniqueScreen> createState() => _TechniqueScreenState();
}

class _TechniqueScreenState extends State<TechniqueScreen>
    with TickerProviderStateMixin {
  late TechniqueScreenBloc _bloc;
  late TabController _tabController;
  late TextEditingController _searchController;
  String _searchQuery = '';
  int index = 0;
  bool isLoading = false;
  late UserModel userProfile;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TechniqueScreenBloc, TechniqueScreenState>(
      builder: _builder,
      listener: _listener,
    );
  }

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _bloc = BlocProvider.of(context);
    userProfile = _bloc.args['favouriteStaff'] as UserModel? ?? UserModel();
    _bloc.add(TechniqueScreenStartedFaEvent());
    _bloc.add(TechniqueScreenStartedEvent());
    _tabController = TabController(length: 2, initialIndex: 0, vsync: this);
    _tabController.addListener(() {
      if (!mounted) return;
      setState(() {
        index = _tabController.index;
      });
    });

    _bloc.users = List.from(_bloc.users);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _listener(BuildContext context, state) {}

  String _getRoleName(UserModel user) {
    if (user.isUserSale()) return "Kinh doanh";
    if (user.isUserRole()) return "Kỹ thuật viên";
    return "Nhân viên";
  }

  Widget _builder(BuildContext context, TechniqueScreenState state) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: MyAppBar(
        title: "Lựa chọn kỹ thuật viên",
        isBackNavigation: true,
        centerTitle: true,
      ),
      body: Column(
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
                  hintText: "Tìm kiếm kỹ thuật viên...",
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

          // Professional Tab Bar
          Container(
            color: Colors.white,
            width: double.infinity,
            child: TabBar(
              controller: _tabController,
              indicatorColor: ColorUtil.bangladeshGreen,
              indicatorWeight: 3,
              labelColor: ColorUtil.bangladeshGreen,
              unselectedLabelColor: Colors.grey.shade400,
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
              tabs: const [
                Tab(text: 'Kỹ thuật viên yêu thích'),
                Tab(text: 'Kỹ thuật viên khác'),
              ],
            ),
          ),

          // Tab views
          Expanded(
            child: IndexedStack(
              index: _tabController.index,
              children: [
                _buildList(_bloc.favouriteStaffs, true),
                _buildList(_bloc.users, false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<UserModel> sourceList, bool isFavoriteTab) {
    final filteredUsers = sourceList.where((user) {
      final name = (user.username ?? '').toLowerCase();
      final phone = (user.phone ?? '').toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || phone.contains(query);
    }).toList();

    if (filteredUsers.isEmpty) {
      return _bloc.isLoading
          ? const SizedBox()
          : _buildEmptyState(isFavoriteTab);
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: filteredUsers.length,
      itemBuilder: (context, index) {
        return _buildUserCard(context, filteredUsers[index]);
      },
    );
  }

  Widget _buildUserCard(BuildContext context, UserModel item) {
    final isSelected = userProfile.id == item.id;
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
        border: Border.all(
          color: isSelected
              ? ColorUtil.bangladeshGreen.withValues(alpha: 0.3)
              : Colors.grey.shade100,
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              _onChooseFavouriteStaff(item);
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

                          // Beautiful check selection visual checkbox
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? ColorUtil.bangladeshGreen
                                  : Colors.transparent,
                              border: Border.all(
                                color: isSelected
                                    ? ColorUtil.bangladeshGreen
                                    : Colors.grey.shade300,
                                width: 2,
                              ),
                            ),
                            child: isSelected
                                ? const Icon(
                                    Icons.check_rounded,
                                    color: Colors.white,
                                    size: 16,
                                  )
                                : null,
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
    final avatarUrl = item.avatar ?? '';
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
          url: avatarUrl,
          height: 52,
          width: 52,
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isFavoriteTab) {
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
                isFavoriteTab
                    ? Icons.favorite_border_rounded
                    : Icons.person_search_rounded,
                size: 64,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isFavoriteTab
                  ? 'Chưa có kỹ thuật viên yêu thích nào'
                  : 'Không tìm thấy kỹ thuật viên',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: MyFontWeight.bold,
                color: ColorUtil.raisinBlack,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isFavoriteTab
                  ? 'Hãy thêm các kỹ thuật viên xuất sắc vào danh sách yêu thích nhé.'
                  : 'Thử tìm kiếm bằng tên hoặc số điện thoại khác xem nhé.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  void _onChooseFavouriteStaff(UserModel? userProfile) {
    if (this.userProfile.id != userProfile?.id) {
      Navigator.pop(context, {
        "initialUserModel": userProfile,
        "favouriteStaff": userProfile,
      });
    }
  }
}
