import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:full_screen_image_null_safe/full_screen_image_null_safe.dart';
import 'package:socbay/blocs/home/feedback/feedback_screen_bloc.dart';
import 'package:socbay/blocs/home/feedback/feedback_screen_event.dart';
import 'package:socbay/blocs/home/feedback/feedback_screen_state.dart';
import 'package:socbay/blocs/staff/comment_and_rating_list/comment_and_rating_list_bloc.dart';
import 'package:socbay/blocs/staff/comment_and_rating_list/comment_and_rating_list_event.dart';
import 'package:socbay/blocs/staff/comment_and_rating_list/comment_and_rating_list_state.dart';
import 'package:socbay/config/app_config.dart';
import 'package:socbay/constants/constants.dart';
import 'package:socbay/data/model/order_detail_model.dart';
import 'package:socbay/data/model/user_model.dart';
import 'package:socbay/routes.dart';
import 'package:socbay/utils/color_util.dart';
import 'package:socbay/utils/image_util.dart';
import 'package:socbay/widgets/button_widget.dart';
import 'package:socbay/widgets/loading_indicator.dart';
import 'package:socbay/widgets/my_app_bar.dart';

class StaffFeedbackScreen extends StatefulWidget {
  final int initialTab;
  const StaffFeedbackScreen({super.key, this.initialTab = 0});

  @override
  State<StaffFeedbackScreen> createState() => _StaffFeedbackScreenState();
}

class _StaffFeedbackScreenState extends State<StaffFeedbackScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Rating & Comment State
  late CommentAndRatingBloc _ratingBloc;
  List<OrderDetailModel>? _lstOrder;

  // Feedback State
  late FeedbackScreenBloc _feedbackBloc;
  late TextEditingController describeRequestTxtController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab,
    );

    _ratingBloc = BlocProvider.of<CommentAndRatingBloc>(context);
    _ratingBloc.add(const CommentAndRatingListEvent());

    _feedbackBloc = BlocProvider.of<FeedbackScreenBloc>(context);
    describeRequestTxtController = TextEditingController();
    _feedbackBloc.add(FeedbackScreenListOfStaffEvent());
  }

  @override
  void dispose() {
    _tabController.dispose();
    describeRequestTxtController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        isBackNavigation: true,
        title: 'Đánh giá & Góp ý',
        centerTitle: true,
        onBack: () {
          Navigator.pop(context);
        },
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Đánh giá & nhận xét'),
            Tab(text: 'Góp ý & khiếu nại'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildRatingAndCommentTab(), _buildFeedbackTab()],
      ),
    );
  }

  // --- TAB 1: Đánh giá & nhận xét ---
  Widget _buildRatingAndCommentTab() {
    return BlocConsumer<CommentAndRatingBloc, CommentAndRatingState>(
      bloc: _ratingBloc,
      listener: (context, state) {
        if (state is CommentAndRatingInitState) {
          _lstOrder = _ratingBloc.lstOrder ?? [];
        }
      },
      builder: (context, state) {
        return RefreshIndicator(
          onRefresh: () async {
            _ratingBloc.add(const CommentAndRatingListEvent());
          },
          child: LoadingIndicator(
            isLoading: _ratingBloc.isLoading,
            child: ListView(
              shrinkWrap: true,
              children: [
                _buildStaffInfo(),
                Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: const Divider(
                      color: Color(0xFFD6D6D6),
                      thickness: 2,
                      height: 30,
                    ),
                  ),
                ),
                _buildStaffCommentAndRatingList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStaffInfo() {
    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.width * 0.2,
        child: Row(children: [_staffImage(), _staffInfo()]),
      ),
    );
  }

  Widget _staffImage() {
    return FullScreenWidget(
      child: Hero(
        tag: "staffImage${_ratingBloc.userProfile?.id}",
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: ImageUtil.loadNetWorkImage(
            url: _ratingBloc.userProfile?.avatar != null
                ? ("$protocol${AppConfig.instance.values.apiUrl}/${_ratingBloc.userProfile!.avatar!}")
                : "$protocol${AppConfig.instance.values.apiUrl}/product_images/ten-san-pham-55.jpg",
            height: MediaQuery.of(context).size.width * 0.18,
            width: MediaQuery.of(context).size.width * 0.18,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Widget _staffInfo() {
    return Wrap(
      spacing: 3.0,
      runSpacing: 4.0,
      direction: Axis.horizontal,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton(
              onPressed: () {
                if (_ratingBloc.userProfile != null) {
                  _goToStaffInfo(_ratingBloc.userProfile!);
                }
              },
              child: Text(
                _ratingBloc.userProfile?.username ?? "",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: ColorUtil.bangladeshGreen,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(_ratingBloc.userProfile?.phone ?? ""),
            ),
            Row(
              children: [
                RatingBarIndicator(
                  rating: _ratingBloc.rating,
                  direction: Axis.horizontal,
                  unratedColor: Colors.amber.withAlpha(23),
                  itemCount: 5,
                  itemSize: 13.0,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) =>
                      const Icon(Icons.star, color: Colors.amber),
                ),
                Text(
                  "(${_ratingBloc.dem.toString()} đánh giá)",
                  style: const TextStyle(fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStaffCommentAndRatingList() {
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16, top: 10),
          child: Text(
            "Các nhận xét đánh giá",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        Column(
          children: [
            ListView.separated(
              padding: const EdgeInsets.only(left: 30.0),
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: _lstOrder?.length ?? 0,
              itemBuilder: _itemRatingBuilder,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ],
    );
  }

  Widget _itemRatingBuilder(BuildContext context, int index) {
    return Wrap(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FullScreenWidget(
              child: Hero(
                tag: "staffImage$index",
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: ImageUtil.loadNetWorkImage(
                    url: _lstOrder?[index].user?.avatar != null
                        ? ("$protocol${AppConfig.instance.values.apiUrl}/${_lstOrder![index].user!.avatar!}")
                        : "",
                    height: MediaQuery.of(context).size.width * 0.2 - 15,
                    width: MediaQuery.of(context).size.width * 0.2 - 15,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.75,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 3.0,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _lstOrder?[index].user?.username ?? "",
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        RatingBarIndicator(
                          rating: _lstOrder?[index].rate != null
                              ? double.parse(_lstOrder![index].rate!)
                              : 0.0,
                          direction: Axis.horizontal,
                          unratedColor: Colors.amber.withAlpha(60),
                          itemCount: 5,
                          itemSize: 11.0,
                          itemPadding: const EdgeInsets.symmetric(
                            horizontal: 3.0,
                          ),
                          itemBuilder: (context, _) =>
                              const Icon(Icons.star, color: Colors.amber),
                        ),
                        const SizedBox(height: 5),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _lstOrder?[index].comment ?? "",
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          Routes.coreReplacementServiceScreen,
                          arguments: {"orderDetail": _lstOrder![index]},
                        );
                      },
                      style: const ButtonStyle(alignment: Alignment.topRight),
                      child: const Text(
                        "Xem chi tiết",
                        style: TextStyle(
                          color: ColorUtil.bangladeshGreen,
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Align(
          alignment: Alignment.center,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            padding: const EdgeInsets.only(top: 5.0),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(width: 0.3, color: Colors.black26),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future _goToStaffInfo(UserModel staffInfo) async {
    await Navigator.pushNamed(
      context,
      Routes.staffInfoScreen,
      arguments: {
        "id": staffInfo.id,
        "name": staffInfo.username,
        "staffInfo": staffInfo,
      },
    );
  }

  // --- TAB 2: Góp ý & khiếu nại ---
  Widget _buildFeedbackTab() {
    return BlocConsumer<FeedbackScreenBloc, FeedbackScreenState>(
      bloc: _feedbackBloc,
      listener: (context, state) {},
      builder: (context, state) {
        if (_feedbackBloc.feedBacksModel.isNotEmpty) {
          return RefreshIndicator(
            onRefresh: () async {
              _feedbackBloc.add(FeedbackScreenListOfStaffEvent());
            },
            child: LoadingIndicator(
              isLoading: _feedbackBloc.isLoading,
              child: ListView.separated(
                itemBuilder: _buildItemServiceHistory,
                separatorBuilder: separatorBuilder,
                itemCount: _feedbackBloc.feedBacksModel.length,
              ),
            ),
          );
        }
        return const Center(child: Text('Lịch sử máy'));
      },
    );
  }

  Widget _buildItemServiceHistory(BuildContext context, int index) {
    return Column(
      children: [
        ButtonWidget(
          onTap: () {
            Navigator.pushNamed(
              context,
              Routes.staffDetailFeedBackScreen,
              arguments: {
                "fbId": _feedbackBloc.feedBacksModel[index].id.toString(),
                "orderId": "0",
              },
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: paddingHorizontal,
              vertical: 8,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.only(bottom: 1),
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: ColorUtil.raisinBlack,
                                width: 1.0,
                              ),
                            ),
                          ),
                          child: Text(
                            'Mã đơn hàng: ĐH_${_feedbackBloc.feedBacksModel[index].orderId}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: ColorUtil.raisinBlack,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 3),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            left: 20,
            top: 0,
            bottom: 10,
            right: 8,
          ),
          child: Table(
            columnWidths: const {1: FlexColumnWidth(2)},
            children: [
              TableRow(
                children: [
                  const Text(
                    "Trạng thái dịch vụ: ",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  Text(_feedbackBloc.feedBacksModel[index].getStatus()),
                ],
              ),
              TableRow(
                children: [
                  const Text(
                    'Mô tả: ',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    _feedbackBloc.feedBacksModel[index].description ?? '',
                    style: const TextStyle(fontSize: 15),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget separatorBuilder(BuildContext context, int index) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(width: 1.0, color: Colors.black26)),
      ),
    );
  }
}
