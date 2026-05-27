import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_format_money_vietnam/flutter_format_money_vietnam.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';
import 'package:socbay/application.dart';
import 'package:socbay/blocs/home/home_bloc.dart';
import 'package:socbay/blocs/home/home_event.dart';
import 'package:socbay/blocs/home/home_state.dart';
import 'package:socbay/config/app_config.dart';
import 'package:socbay/constants/constants.dart';
import 'package:socbay/data/model/home_service_model.dart';
import 'package:socbay/data/model/order_detail_model.dart';
import 'package:socbay/routes.dart';
import 'package:socbay/utils/context_extension.dart';
import 'package:socbay/widgets/button_widget.dart';
import 'package:socbay/widgets/loading_indicator.dart';
import 'package:socbay/widgets/my_app_bar.dart';
import 'package:socbay/widgets/my_rich_text.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/model/order_model.dart';
import '../../paths/images.dart';
import '../../utils/color_util.dart';
import '../../utils/image_util.dart';
import '../../widgets/banner_widget.dart';
import '../../widgets/box_shadow_widget.dart';
import '../../widgets/header_card_widget.dart';
import '../../widgets/status_bar_color_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late HomeBloc _bloc;

  @override
  void initState() {
    if (kDebugMode) {
      print("INIT HOME");
    }
    super.initState();
    _bloc = BlocProvider.of(context);
    _bloc.add(HomeStartedEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeBloc, HomeState>(
      builder: _builder,
      listener: _listener,
    );
  }

  void _listener(BuildContext context, state) {}

  Widget _builder(BuildContext context, state) {
    return LoadingIndicator(
      isLoading: _bloc.isLoading,
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          heroTag: "home",
          backgroundColor: ColorUtil.brightYellow,
          shape: const CircleBorder(
            side: BorderSide(color: Colors.white, width: 3.0),
          ),
          tooltip: "Thêm công việc",
          onPressed: () {
            Navigator.pushNamed(
              context,
              App.instance.userApp?.isUserCustomer() == true
                  ? Routes.serviceScreen
                  : App.instance.userApp?.isUserRole() == true
                  ? Routes.staffServiceScreen
                  : Routes.staffServiceScreenSale,
              arguments: {"listService": _bloc.services, "index": ""},
            );
          },
          child: const Icon(Icons.add),
        ),
        appBar: _buildAppBar(),
        body: RefreshIndicator(
          onRefresh: _onRefresh,
          child: ListView(
            shrinkWrap: true,
            children: [
              const StatusBarColorWidget(),

              /// summary
              _buildSummary(),

              /// banner
              const SizedBox(height: paddingVertical),
              if (_bloc.banners.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: paddingHorizontal,
                  ),
                  child: BannerSliderWidget(banners: _bloc.banners),
                ),

              //product info
              if (App.instance.userApp?.isUserCustomer() == true)
                _buildProductInfo(),

              /// service
              const SizedBox(height: 15),
              _buildService(),

              /// news
              const SizedBox(height: 20),
              buildBlogs(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  MyAppBar _buildAppBar() {
    return MyAppBar(
      leadWidget: IconButton(
        onPressed: _onPressMenu,
        padding: EdgeInsets.zero,
        icon: const Icon(Icons.menu, color: Colors.white),
      ),
      actionWidgets: [
        IconButton(
          onPressed: _onPressNotification,
          icon: ImageUtil.loadAssetsImage(
            fileName: Images.iconNoti,
            width: 25,
            height: 25,
          ),
        ),
      ],
      titleWidget: MyRichText(
        firstText: "Xin Chào, ",
        mainAxisAlignment: MainAxisAlignment.start,
        secondText: '${App.instance.userApp?.username}',
        firstTextStyle: const TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.bold,
        ),
        secondTextStyle: const TextStyle(
          overflow: TextOverflow.ellipsis,
          fontSize: 19,
          color: ColorUtil.raisinBlack,
          fontWeight: FontWeight.bold,
        ),
        onTapSecond: () {},
      ),
    );
  }

  Widget _buildProductInfo() {
    if (_bloc.lstMachine.isEmpty) {
      return _buildEmptyMachineWidget(context);
    } else {
      return SizedBox(
        height: 430,
        child: ListView.builder(
          shrinkWrap: false,
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: _bloc.lstMachine.length,
          itemBuilder: _buildMachineItem,
        ),
      );
    }
  }

  void _detailMachine(OrderModel orderModel) {
    Navigator.pushNamed(
      context,
      Routes.machineDetail,
      arguments: {
        'id_oder': orderModel,
        'id_user': App.instance.userApp?.phone.toString(),
      },
    );
  }

  String _formatDateTime(String? dateTimeString) {
    try {
      var dateTime = dateTimeString ?? DateTime.now().toString();
      DateTime getDateTime = DateTime.parse(dateTime);
      var output = DateFormat('dd/MM/yyyy HH:mm:ss').format(getDateTime);
      return output.toString();
    } catch (ex) {
      rethrow;
    }
  }

  Widget _buildEmptyMachineWidget(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, Routes.userNewOrderScreen);
      },
      child: Container(
        width: 340,
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: ColorUtil.bangladeshGreen),
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            const HeaderCardWidget(text: 'Nhật ký thay lõi', isViewMore: false),
            const SizedBox(height: 45),
            ImageUtil.loadAssetsImage(
              fileName: Images.iconAddProduct, // Placeholder image
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 20),
            const Text(
              'Chưa có nhật ký thay lõi',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Bấm để thêm mới',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMachineItem(BuildContext context, int index) {
    int reversedIndex = _bloc.lstMachine.length - 1 - index;
    OrderModel machine = _bloc.lstMachine[reversedIndex];

    var dataFormat = _formatDateTime(machine.createdAt);
    return InkWell(
      onTap: () {
        _detailMachine(machine);
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        margin: const EdgeInsets.only(left: 30, top: 5, bottom: 5),
        // margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: ColorUtil.bangladeshGreen),
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const HeaderCardWidget(text: 'Nhật ký thay lõi', isViewMore: false),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: ImageUtil.loadNetWorkImage(
                url: machine.product?.images?[0].link == null
                    ? ""
                    : "$protocol${AppConfig.instance.values.apiUrl}${machine.product!.images![0].link!}",
                height: MediaQuery.of(context).size.width * 0.5,
                width: MediaQuery.of(context).size.width * 0.5,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              width: MediaQuery.of(context).size.width * 0.74,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${machine.product?.name}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: ColorUtil.raisinBlack,
                      fontSize: 16,
                    ),
                  ),
                  Wrap(
                    //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    spacing: 8.0, // gap between adjacent chips
                    runSpacing: 4.0, // gap between lines
                    direction: Axis.horizontal, // main axis (rows or columns)
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.width * 0.01,
                          ),
                          child: (RichText(
                            softWrap: true,
                            maxLines: 3,
                            text: TextSpan(
                              children: [
                                const TextSpan(
                                  text: 'Số cấp lọc: ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: ColorUtil.bangladeshGreen,
                                    decorationThickness: 1,
                                    fontSize: 15,
                                  ),
                                ),
                                TextSpan(
                                  text: machine.filterCoreLevel ?? "0",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.normal,
                                    color: ColorUtil.raisinBlack,
                                    decorationThickness: 1,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          )),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.width * 0.01,
                          ),
                          child: (RichText(
                            softWrap: true,
                            maxLines: 3,
                            text: TextSpan(
                              children: [
                                const TextSpan(
                                  text: 'Ngày mua: ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: ColorUtil.bangladeshGreen,
                                    decorationThickness: 1,
                                    fontSize: 13,
                                  ),
                                ),
                                TextSpan(
                                  text: dataFormat,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.normal,
                                    color: ColorUtil.raisinBlack,
                                    decorationThickness: 1,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          )),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.width * 0.01,
                          ),
                          child: (RichText(
                            softWrap: true,
                            maxLines: 3,
                            text: TextSpan(
                              children: [
                                const TextSpan(
                                  text: 'Ngày thay tiếp theo: ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: ColorUtil.bangladeshGreen,
                                    decorationThickness: 1,
                                    fontSize: 15,
                                  ),
                                ),
                                TextSpan(
                                  text: _bloc
                                      .orderFilterCore[index]
                                      .replaceDatePromise,
                                  // text: machine.orderFilterCoresModel?[0].replaceDatePromise,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.normal,
                                    decorationThickness: 1,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          )),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary() {
    return SizedBox(
      height: 160,
      child: Stack(
        children: [
          Container(
            height: 100,
            width: double.infinity,
            color: ColorUtil.bangladeshGreen,
            child: Column(children: const [SizedBox(height: 8)]),
          ),
          Positioned(
            bottom: 0,
            left: paddingHorizontal,
            right: paddingHorizontal,
            child: Container(
              height: 130,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.4),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 2), // changes position of shadow
                  ),
                ],
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: paddingHorizontal,
                      vertical: 10,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          "Thay lõi lọc nước SocBay",
                          style: TextStyle(
                            color: ColorUtil.bangladeshGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: Colors.grey.withOpacity(0.7)),
                  Expanded(
                    child: Row(
                      children: [
                        if (App.instance.userApp?.isUserCustomer() ??
                            false) ...[
                          _buildBoxSummary(
                            context,
                            "Tích điểm",
                            "${_bloc.user?.point ?? 0}",
                            Images.iconPoint,
                          ),
                          Container(
                            width: 1,
                            color: Colors.grey.withOpacity(0.7),
                          ),
                        ] else if (App.instance.userApp?.isUserRole() ??
                            false) ...[
                          _buildBoxSummary(
                            context,
                            "Tổng đơn",
                            "${_bloc.totalOrderAll}",
                            Images.iconFeedback,
                          ),
                          _buildBoxSummary(
                            context,
                            "Doanh số",
                            _bloc.totalPriceAll.toInt().toVND(),
                            Images.iconPoint,
                          ),
                        ] else ...[
                          _buildBoxSummary(
                            context,
                            "Tổng đơn",
                            "${_bloc.totalOrderAll}",
                            Images.iconFeedback,
                          ),
                          _buildBoxSummary(
                            context,
                            "Doanh số",
                            _bloc.totalPriceAll.toInt().toVND(),
                            Images.iconStats,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildContainer(
    BuildContext context,
    String title,
    String value,
    String image,
  ) {
    return Expanded(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: ImageUtil.loadAssetsImage(
                    fileName: image,
                    width: 20,
                    height: 20,
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: ColorUtil.bangladeshGreen,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              alignment: Alignment.center,
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 17,
                  color: ColorUtil.bangladeshGreen,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoxSummary(
    BuildContext context,
    String title,
    String value,
    String image, {
    void Function()? onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: ImageUtil.loadAssetsImage(
                      fileName: image,
                      width: 20,
                      height: 20,
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: ColorUtil.bangladeshGreen,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                alignment: Alignment.center,
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 17,
                    color: ColorUtil.bangladeshGreen,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildService() {
    return BoxShadowWidget(
      child: Column(
        children: [
          const HeaderCardWidget(text: 'Dịch vụ tại nhà', isViewMore: false),
          AlignedGridView.count(
            padding: const EdgeInsets.symmetric(
              horizontal: paddingHorizontal,
              vertical: paddingVertical,
            ),
            addRepaintBoundaries: false,
            shrinkWrap: true,
            itemCount: _bloc.allServices.length,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            crossAxisCount: 3,
            itemBuilder: _itemService,
          ),
        ],
      ),
    );
  }

  Widget _itemService(BuildContext context, int index) {
    final HomeServiceModel itemHomeService = _bloc.allServices[index];
    final widthImage = (context.width - 80) / 3 - 60;
    final heightImage = (context.width - 60) / 3 - 60;

    return ButtonWidget(
      onTap: () {
        if (App.instance.userApp?.isUserCustomer() == true) {
          if (index == 0) {
            Navigator.pushNamed(
              context,
              Routes.serviceScreen,
              arguments: {
                "index": index.toString(),
                "listService": _bloc.services,
              },
            );
          } else if (index == 1) {
            const url = "tel:0963456911";
            launchUrl(Uri.parse(url));
          } else if (index == 2) {
            Navigator.pushNamed(
              context,
              Routes.feedbackScreen,
              arguments: {"fbId": "0", "orderId": "0"},
            );
          } else if (index == 3) {
            Navigator.pushNamed(context, Routes.hotlineScreen);
          } else if (index == 4) {
            Navigator.pushNamed(
              context,
              Routes.coreReplacementServiceScreen,
              arguments: {
                "orderDetail": OrderDetailModel(
                  id: int.parse(_bloc.orderFilterCore[0].orderId ?? "0"),
                ),
              },
            );
          }
        } else if (App.instance.userApp?.isUserRole() == true) {
          if (index == 0) {
            Navigator.pushNamed(context, Routes.staffCommentAndRatingList);
          } else if (index == 1) {
            Navigator.pushNamed(context, Routes.orderManagerScreen);
          } else if (index == 2) {
            Navigator.pushNamed(context, Routes.notificationScreen);
          } else if (index == 3) {
            Navigator.pushNamed(context, Routes.newsScreen);
          } else if (index == 4) {
            Navigator.pushNamed(
              context,
              Routes.staffFeedbackScreen,
              arguments: {"fbId": "0", "orderId": "0"},
            );
          }
        } else {
          if (index == 0) {
            Navigator.pushNamed(context, Routes.evaluateScreen);
          } else if (index == 1) {
            Navigator.pushNamed(context, Routes.orderManagerScreenBySale);
          } else if (index == 2) {
            Navigator.pushNamed(context, Routes.notificationScreen);
          } else if (index == 3) {
            Navigator.pushNamed(context, Routes.feedbackkScreen);
          } else if (index == 4) {
            Navigator.pushNamed(context, Routes.staffCustomerInformationList);
          } else if (index == 5) {
            Navigator.pushNamed(
              context,
              Routes.rentBookingServiceScreen,
              arguments: {
                "index": index.toString(),
                "listService": _bloc.services,
              },
            );
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: ColorUtil.bangladeshGreen.withOpacity(0.4)),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          children: [
            ImageUtil.loadAssetsImage(
              fileName: itemHomeService.image ?? "",
              width: widthImage,
              height: heightImage,
            ),
            const SizedBox(height: 7),
            if (App.instance.userApp?.isUserCustomer() == true &&
                index == 4) ...[
              SizedBox(
                height: 30,
                child: Text(
                  itemHomeService.name ?? "",
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: const TextStyle(
                    fontSize: 13,
                    color: ColorUtil.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ] else ...[
              SizedBox(
                height: 30,
                child: Text(
                  itemHomeService.name ?? "",
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: const TextStyle(
                    fontSize: 13,
                    color: ColorUtil.bangladeshGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
            Html(
              data: itemHomeService.des ?? "",
              style: {
                '#': Style(
                  fontSize: FontSize(11),
                  maxLines: 3,
                  textOverflow: TextOverflow.ellipsis,
                  color: Colors.black,
                  textAlign: TextAlign.center,
                ),
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildBlogs() {
    return BoxShadowWidget(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          HeaderCardWidget(text: "Tin tức", onViewMore: _goToListNews),
          ListView.separated(
            padding: const EdgeInsets.symmetric(
              horizontal: paddingHorizontal,
              vertical: paddingVertical,
            ),
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: _bloc.blogs.length >= 5 ? 5 : _bloc.blogs.length,
            itemBuilder: _buildItemBlog,
            separatorBuilder: _separateView,
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _separateView(BuildContext context, int index) {
    return const SizedBox(height: 8);
  }

  Widget _buildItemBlog(BuildContext context, int index) {
    final itemBlog = _bloc.blogs[index];
    return ButtonWidget(
      onTap: () {
        Navigator.pushNamed(context, Routes.newDetail, arguments: itemBlog);
      },
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: ImageUtil.loadNetWorkImage(
              url: itemBlog.image == null
                  ? ""
                  : "$protocol${AppConfig.instance.values.apiUrl}${itemBlog.image!}",
              fit: BoxFit.cover,
              height: 100,
              width: 100,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${itemBlog.name}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: ColorUtil.bangladeshGreen,
                  ),
                ),
                // Padding(
                //   padding: const EdgeInsets.symmetric(vertical: 4),
                //   child: Html(data: itemBlog.shortdes ?? ""),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onPressNotification() {
    Navigator.pushNamed(context, Routes.notificationScreen);
  }

  void _onPressMenu() {
    Navigator.pushNamed(context, Routes.userProfileScreen);
  }

  void _goToListNews() {
    Navigator.pushNamed(context, Routes.newsScreen);
  }

  Future<void> _onRefresh() async {
    _bloc.add(HomeStartedEvent());
  }
}
