import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:full_screen_image_null_safe/full_screen_image_null_safe.dart';
import 'package:socbay/blocs/home/staff_info/staff_info_screen_bloc.dart';
import 'package:socbay/blocs/home/staff_info/staff_info_screen_event.dart';
import 'package:socbay/blocs/home/staff_info/staff_info_screen_state.dart';
import 'package:socbay/config/app_config.dart';
import 'package:socbay/constants/constants.dart';
import 'package:socbay/data/model/user_profile.dart';
import 'package:socbay/paths/images.dart';
import 'package:socbay/utils/color_util.dart';
import 'package:socbay/utils/image_util.dart';
import 'package:socbay/utils/theme_util.dart';
import 'package:socbay/widgets/dialog/custom_alert_dialog.dart';
import 'package:socbay/widgets/loading_indicator.dart';
import 'package:socbay/widgets/my_app_bar.dart';

import '../../data/model/order_detail_model.dart';

class StaffInfoScreen extends StatefulWidget {
  const StaffInfoScreen({super.key});

  @override
  State<StaffInfoScreen> createState() => _StaffInfoScreenState();
}

class _StaffInfoScreenState extends State<StaffInfoScreen> {
  late StaffInfoScreenBloc _bloc;
  late UserProfile staffInfo;

  List<OrderDetailModel>? _lstOrder;
  bool isPickDone = false;
  String _localte = "";
  List<String> _services = [];

  @override
  void initState() {
    _bloc = BlocProvider.of(context);

    staffInfo = _bloc.args["staffInfo"];
    _bloc.add(StaffInfoScreenStartedEvent());
    _bloc.add(const StaffInfoScreenListEvent());
    super.initState();
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StaffInfoScreenBloc, StaffInfoScreenState>(
        builder: _builder, listener: _listener);
  }

  void _listener(BuildContext context, StaffInfoScreenState state) {
    if (state is StaffInfoScreenInitialState) {
      setState(() {
        _localte = _bloc.localte;
        _services = _bloc.services;
        _lstOrder = _bloc.lstOrder ?? [];
      });
    }
    if (state is StaffInfoScreenWaitingState) {
      startCountdown();
      CustomAlertDialog.show(
        context,
        content: "Chờ xử lý",
        rightText: "Hủy",
        asset: Images.iconHotline,
        isLeftPositive: true,
        backListener: () {},
        isShowTitle: false,
        rightAction: () {
          Navigator.of(context).pop();
        },
      );
    }

    if (state is StaffInfoScreenPickSuccessState) {
      Navigator.of(context).pop();
      CustomAlertDialog.show(
        context,
        title: "Thông báo",
        content:
            "Yêu cầu của bạn đã được tiếp nhận kỹ thuật viên sẽ liên hệ với bạn ngay",
        leftText: "OK",
        isLeftPositive: true,
        backListener: () {},
        isShowTitle: false,
        leftAction: () {
          setState(() {
            isPickDone = true;
          });
          Navigator.of(context).pop();
        },
      );
    }

    if (state is StaffInfoScreenPickFailedState) {
      Navigator.of(context).pop();
      CustomAlertDialog.show(
        context,
        title: "Thông báo",
        content:
            "Rất tiếc kỹ thuật viên không thể nhận được yêu cầu dịch vụ của bạn ngay lúc này. Vui lòng lựa chọn kỹ thuật viên khác",
        leftText: "OK",
        isLeftPositive: true,
        backListener: () {},
        isShowTitle: false,
        leftAction: () {
          setState(() {
            isPickDone = true;
          });
          Navigator.of(context).pop();
        },
      );
    }
  }

  Widget _builder(BuildContext context, StaffInfoScreenState state) {
    return Scaffold(
      appBar: MyAppBar(
        isBackNavigation: true,
        title: 'Thông tin kỹ thuật viên',
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _bloc.add(const StaffInfoScreenListEvent());
        },
        child: LoadingIndicator(
          isLoading: _bloc.isLoading,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: paddingHorizontal,
              vertical: paddingVertical,
            ),
            child: ListView(
              children: [
                Row(
                  children: [
                    staffInfo.avatar != null
                        ? fullScreenHeroWidget(
                            "$protocol${AppConfig.instance.values.apiUrl}/${staffInfo.avatar!}",
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: ImageUtil.loadNetWorkImage(
                              url: "$protocol${AppConfig.instance.values.apiUrl}/product_images/ktv-avatar.jpg",
                              height: 100,
                              width: 100,
                            ),
                          ),
                    const SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${staffInfo.username}',
                          style: const TextStyle(
                            color: ColorUtil.bangladeshGreen,
                            fontSize: 20,
                            fontWeight: MyFontWeight.extraBold,
                          ),
                        ),
                        Text(
                          '${staffInfo.phone}',
                          style: const TextStyle(
                            color: ColorUtil.raisinBlack,
                            fontWeight: MyFontWeight.ultraBold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Wrap(
                          spacing: 3.0,
                          runSpacing: 4.0,
                          direction: Axis.horizontal,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    RatingBarIndicator(
                                      rating: _bloc.rating,
                                      direction: Axis.horizontal,
                                      unratedColor: Colors.amber.withAlpha(23),
                                      itemCount: 5,
                                      itemSize: 13.0,
                                      itemPadding: const EdgeInsets.symmetric(
                                        horizontal: 4.0,
                                      ),
                                      itemBuilder: (context, _) => const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                      ),
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
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Thông tin kỹ thuật',
                  style: TextStyle(
                    color: ColorUtil.raisinBlack,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    ImageUtil.loadAssetsImage(
                      fileName: staffInfo.phone!.isNotEmpty
                          ? Images.iconCheck
                          : Images.iconCancel,
                      width: 16,
                      height: 16,
                    ),
                    const SizedBox(width: 4),
                    const Text('Đã xác minh số điện thoại'),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    ImageUtil.loadAssetsImage(
                      fileName: staffInfo.cmt != null
                          ? Images.iconCheck
                          : Images.iconCancel,
                      width: 16,
                      height: 16,
                    ),
                    const SizedBox(width: 4),
                    const Text('Đã xác minh chứng minh thư'),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Dịch vụ cung cấp',
                  style: TextStyle(
                    color: ColorUtil.raisinBlack,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                _services.isNotEmpty
                    ? Wrap(
                        children: _services
                            .map(
                              (service) => Container(
                                margin: const EdgeInsets.only(left: 3.0),
                                child: TextButton(
                                  onPressed: () {},
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                      width: 1.0,
                                      color: ColorUtil.bangladeshGreen,
                                    ),
                                    padding: const EdgeInsets.all(10.0),
                                  ),
                                  child: Text(service),
                                ),
                              ),
                            )
                            .toList(),
                      )
                    : const Text(
                        'Trống!',
                        style: TextStyle(
                          color: ColorUtil.bangladeshGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                const SizedBox(height: 10),
                const Text(
                  'Khu vực',
                  style: TextStyle(
                    color: ColorUtil.raisinBlack,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _localte,
                  style: const TextStyle(
                    color: ColorUtil.bangladeshGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Lưu vào mục ưa thích',
                      style: TextStyle(
                        color: ColorUtil.raisinBlack,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        _saveFavouriteStaff();
                      },
                      icon: _bloc.isFavourite
                          ? const Icon(
                              Icons.favorite,
                              color: ColorUtil.red,
                            )
                          : const Icon(Icons.favorite_border_outlined),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildStaffCommentAndRatingList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _saveFavouriteStaff() {
    if (_bloc.isFavourite) {
      _bloc.add(StaffInfoScreenUnLikeStaffEvent(staffInfo.id!));
    } else {
      _bloc.add(StaffInfoScreenLikeStaffEvent(staffInfo.id!));
    }
  }

  void startCountdown() {
    Future.delayed(const Duration(seconds: 60), () {
      Navigator.of(context).pop();
      CustomAlertDialog.show(
        context,
        title: "Thông báo",
        content:
            "Rất tiếc kỹ thuật viên không thể nhận được yêu cầu dịch vụ của bạn ngay lúc này. Vui lòng lựa chọn kỹ thuật viên khác",
        leftText: "OK",
        isLeftPositive: true,
        backListener: () {},
        isShowTitle: false,
        leftAction: () {
          setState(() {
            isPickDone = true;
          });
          Navigator.of(context).pop();
        },
      );
    });
  }

  Widget fullScreenHeroWidget(String img) {
    return FullScreenWidget(
      child: Hero(
        tag: img,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: ImageUtil.loadNetWorkImage(
              url: img, height: 100, fit: BoxFit.contain),
        ),
      ),
    );
  }

  Widget _buildStaffCommentAndRatingList() {
    return Wrap(
      spacing: 8.0, // gap between adjacent chips
      runSpacing: 4.0, // gap between lines
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
              itemBuilder: _itemBuilder,
              separatorBuilder: _separateView,
            ),
            const SizedBox(height: 10)
          ],
        ),
      ],
    );
  }

  Widget _itemBuilder(BuildContext context, int index) {
    return Wrap(
      children: [
        Row(mainAxisSize: MainAxisSize.min, children: [
          FullScreenWidget(
            child: Hero(
              tag: "staffImage$index",
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: ImageUtil.loadNetWorkImage(
                    url: _lstOrder?[index].user?.avatar != null
                        ? ("$protocol${AppConfig.instance.values.apiUrl}/${_lstOrder![index].user!.avatar!}")
                        : "",
                    height: MediaQuery.of(context).size.width * 0.12 - 15,
                    width: MediaQuery.of(context).size.width * 0.12 - 15,
                    fit: BoxFit.contain),
              ),
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.75,
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 3.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _lstOrder?[index].user?.username ?? "",
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      RatingBarIndicator(
                        rating: _lstOrder?[index].rate != null
                            ? double.parse(_lstOrder![index].rate!)
                            : 0.0,
                        direction: Axis.horizontal,
                        unratedColor: Colors.amber.withAlpha(60),
                        itemCount: 5,
                        itemSize: 10.0,
                        itemPadding:
                            const EdgeInsets.symmetric(horizontal: 3.0),
                        itemBuilder: (context, _) => const Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(_lstOrder?[index].comment ?? "",
                            overflow: TextOverflow.ellipsis, // default is .clip
                            maxLines: 2),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ]),
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
        )
      ],
    );
  }

  Widget _separateView(BuildContext context, int index) {
    return const SizedBox(height: 8);
  }
}
