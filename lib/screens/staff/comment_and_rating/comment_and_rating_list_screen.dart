import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:full_screen_image_null_safe/full_screen_image_null_safe.dart';
import 'package:socbay/blocs/staff/comment_and_rating_list/comment_and_rating_list_bloc.dart';
import 'package:socbay/blocs/staff/comment_and_rating_list/comment_and_rating_list_event.dart';
import 'package:socbay/blocs/staff/comment_and_rating_list/comment_and_rating_list_state.dart';
import 'package:socbay/config/app_config.dart';
import 'package:socbay/data/model/order_detail_model.dart';
import 'package:socbay/data/model/user_model.dart';
import 'package:socbay/routes.dart';
import 'package:socbay/utils/color_util.dart';
import 'package:socbay/utils/image_util.dart';
import 'package:socbay/widgets/loading_indicator.dart';
import 'package:socbay/widgets/my_app_bar.dart';

class CommentAndRatingListScreen extends StatefulWidget {
  const CommentAndRatingListScreen({super.key});

  @override
  State<CommentAndRatingListScreen> createState() =>
      _CommentAndRatingListScreenState();
}

class _CommentAndRatingListScreenState
    extends State<CommentAndRatingListScreen> {
  late CommentAndRatingBloc _bloc;
  List<OrderDetailModel>? _lstOrder;
  @override
  void initState() {
    _bloc = BlocProvider.of(context);
    _bloc.add(const CommentAndRatingListEvent());
    super.initState();
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CommentAndRatingBloc, CommentAndRatingState>(
      builder: _builder,
      listener: _listener,
    );
  }

  void _listener(BuildContext context, CommentAndRatingState state) {
    if (state is CommentAndRatingInitState) {
      // var lst = _bloc.lstOrder?.where((element) => element.rate != null && element.comment!= null && element.comment!.isNotEmpty ).toList();
      // _lstOrder = lst!= null && lst.isNotEmpty? lst:[];
      _lstOrder = _bloc.lstOrder ?? [];
    }
  }

  Widget _builder(BuildContext context, CommentAndRatingState state) {
    return Scaffold(
      appBar: MyAppBar(title: "Đánh giá và nhận xét", isBackNavigation: true),
      body: RefreshIndicator(
        onRefresh: () async {
          _bloc.add(const CommentAndRatingListEvent());
        },
        child: LoadingIndicator(
          isLoading: _bloc.isLoading,
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
      ),
    );
  }

  Widget _buildStaffInfo() {
    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.width * 0.2,
        child: Row(
          children: [_staffImage(), _staffInfo()],
          //height: 300,
        ),
      ),
    );
  }

  Widget _buildStaffCommentAndRatingList() {
    return Wrap(
      spacing: 8.0, // gap between adjacent chips
      runSpacing: 4.0, // gap between lines
      //direction: Axis.horizontal, // main axis (rows or columns)
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16, top: 10),
          child: Text(
            "Các nhận xét đánh giá",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        Column(
          //mainAxisSize: MainAxisSize.max,
          //crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListView.separated(
              padding: const EdgeInsets.only(left: 30.0),
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: _lstOrder?.length ?? 0,
              itemBuilder: _itemBuilder,
              separatorBuilder: _separateView,
            ),
            const SizedBox(height: 10),
          ],
        ),
      ],
    );
  }

  Widget _itemBuilder(BuildContext context, int index) {
    return Wrap(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          // onTap: () {
          //   Navigator.pushNamed(context, Routes.coreReplatementServiceScreen,
          //       arguments: {"orderDetail":_bloc.ordersModel[index]});
          // },
          //   spacing: 8.0, // gap between adjacent chips
          //   runSpacing: 4.0, // gap between lines
          //   direction: Axis.horizontal, // main axis (rows or columns)
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
                  //fit: BoxFit.cover,
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
                        // Row(
                        //   children: [
                        //
                        //   ],
                        // ),
                        const SizedBox(height: 5),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _lstOrder?[index].comment ?? "",
                            overflow: TextOverflow.ellipsis, // default is .clip
                            maxLines: 2,
                          ),
                          // child: Text("ExpansionTile({Key? key, Widget? leading, required Widget title, "
                          //     "Widget? subtitle, ValueChanged<bool>? onExpansionChanged, "
                          //     "List<Widget> children = const <Widget>[], Widget? trailing, "
                          //     "bool initiallyExpanded = false, bool maintainState = false, "
                          //     "EdgeInsetsGeometry? tilePadding, CrossAxisAlignment? expandedCrossAxisAlignment, "
                          //     "Alignment? expandedAlignment, EdgeInsetsGeometry? childrenPadding, Color? backgroundColor, "
                          //     "Color? collapsedBackgroundColor, Color? textColor, Color? collapsedTextColor, "
                          //     "Color? iconColor, Color? collapsedIconColor, ShapeBorder? shape, ShapeBorder? collapsedShape, "
                          //     "Clip? clipBehavior, ListTileControlAffinity? controlAffinity, ExpansionTileController? controller",overflow: TextOverflow.ellipsis, // default is .clip
                          //     maxLines: 2),
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

  Widget _staffImage() {
    return FullScreenWidget(
      child: Hero(
        tag: "staffImage${_bloc.userProfile?.id}",
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: ImageUtil.loadNetWorkImage(
            url: _bloc.userProfile?.avatar != null
                ? ("$protocol${AppConfig.instance.values.apiUrl}/${_bloc.userProfile!.avatar!}")
                : "$protocol${AppConfig.instance.values.apiUrl}/product_images/ten-san-pham-55.jpg",
            height: MediaQuery.of(context).size.width * 0.18,
            width: MediaQuery.of(context).size.width * 0.18,
            fit: BoxFit.contain,
          ),
          //fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _staffInfo() {
    return Wrap(
      spacing: 3.0, // gap between adjacent chips
      runSpacing: 4.0, // gap between lines
      direction: Axis.horizontal, // main axis (rows or columns)
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton(
              onPressed: () {
                _goToStaffInfo(_bloc.userProfile!);
              },
              child: Text(
                _bloc.userProfile?.username ?? "",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: ColorUtil.bangladeshGreen,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(_bloc.userProfile?.phone ?? ""),
            ),
            Row(
              children: [
                RatingBarIndicator(
                  rating: _bloc.rating,
                  direction: Axis.horizontal,
                  unratedColor: Colors.amber.withAlpha(23),
                  itemCount: 5,
                  itemSize: 13.0,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) =>
                      const Icon(Icons.star, color: Colors.amber),
                ),
                Text(
                  "(${_bloc.dem.toString()} đánh giá)",
                  style: const TextStyle(fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _separateView(BuildContext context, int index) {
    return const SizedBox(height: 8);
  }

  Future _goToStaffInfo(UserModel staffInfo) async {
    await Navigator.pushNamed(
      context,
      Routes.staffInfoScreen,
      arguments: {
        "id": staffInfo.id,
        "name": staffInfo.username,
        //"idService": staffInfo,
        "staffInfo": staffInfo,
      },
    );
  }
}
