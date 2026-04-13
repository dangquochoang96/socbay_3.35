import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:socbay/application.dart';
import 'package:socbay/constants/constants.dart';
import 'package:socbay/data/model/gift_response.dart';
import 'package:socbay/data/repository/auth/api_repository.dart';
import 'package:socbay/utils/color_util.dart';
import 'package:socbay/utils/context_extension.dart';
import 'package:socbay/utils/image_util.dart';
import 'package:socbay/utils/theme_util.dart';
import 'package:socbay/widgets/dialog/custom_alert_dialog.dart';
import 'package:socbay/widgets/loading_indicator.dart';
import 'package:socbay/widgets/my_app_bar.dart';
import 'package:socbay/widgets/my_button.dart';

import '../../data/event_bus/event_bus_event.dart';

class GiftDetailScreen extends StatefulWidget {
  const GiftDetailScreen({Key? key, required this.args}) : super(key: key);
  final Map<String, dynamic> args;

  @override
  State<GiftDetailScreen> createState() => _GiftDetailScreenState();
}

class _GiftDetailScreenState extends State<GiftDetailScreen> {
  GiftResponse? giftResponse;
  bool isMyGift = false;
  late ApiRepository apiRepository;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      giftResponse = widget.args["gift"] as GiftResponse;
      isMyGift = widget.args["is_my_gift"] as bool;
    });
    apiRepository = RepositoryProvider.of(context);
  }

  @override
  Widget build(BuildContext context) {
    return LoadingIndicator(
      isLoading: isLoading,
      child: Scaffold(
        appBar: MyAppBar(
            isBackNavigation: true, centerTitle: true, title: "Chi tiết quà"),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: paddingHorizontal,
                    vertical: paddingVertical,
                  ),
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(21),
                          child: ImageUtil.loadNetWorkImage(
                              url: giftResponse?.image ?? '',
                              height: context.width - paddingHorizontal * 2),
                        ),
                        // Positioned(
                        //   bottom: 0,
                        //   right: 0,
                        //   child: Row(
                        //     children: [
                        //       IconButton(
                        //         icon: ImageUtil.loadAssetsImage(
                        //             fileName: "ic_share.svg", color: Colors.grey),
                        //         onPressed: () {},
                        //       ),
                        //       IconButton(
                        //         icon: ImageUtil.loadAssetsImage(
                        //             fileName: "ic_heart.svg",
                        //             color: giftResponse. == 1
                        //                 ? Colors.red
                        //                 : Colors.grey),
                        //         onPressed: () {},
                        //       )
                        //     ],
                        //   ),
                        // )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        "${giftResponse?.name}",
                        style: const TextStyle(
                            color: ColorUtil.bangladeshGreen,
                            fontSize: 20,
                            fontWeight: MyFontWeight.bold),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("${giftResponse?.point} điểm",
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: ColorUtil.brightYellow)),
                      ],
                    ),
                    const Divider(color: Colors.grey, thickness: 1, height: 40),
                    const Text(
                      "Mô tả:",
                      style: TextStyle(
                          color: ColorUtil.bangladeshGreen,
                          fontWeight: MyFontWeight.bold,
                          fontSize: 18),
                    ),
                    Html(data: giftResponse?.description),
                  ],
                ),
              ),
              if (isMyGift)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: paddingHorizontal,
                    vertical: 8,
                  ),
                  child: DefaultButton(
                    width: double.infinity,
                    onPressed: () async {
                      if (giftResponse?.id == null) {
                        context.showSnackBarError("id null");
                        return;
                      }
                      setState(() {
                        isLoading = true;
                      });
                      final res =
                          await apiRepository.exchangeGift(giftResponse!.id!);
                      if (res.status == HttpStatus.ok) {
                        CustomAlertDialog.show(
                          context,
                          isShowTitle: false,
                          content: "Đổi quả thành công",
                          leftText: "Ok",
                          leftAction: () {
                            Navigator.pop(context, true);
                            Navigator.pop(context, true);
                            App.instance.eventBus.fire(EventBusReloadGiftEvent());
                          },
                        );
                      } else {
                        context
                            .showSnackBarError(res.message ?? "Có lỗi xảy ra");
                      }
                      setState(() {
                        isLoading = false;
                      });
                    },
                    text: "Đổi quả",
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
