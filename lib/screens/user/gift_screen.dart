import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:socbay/blocs/user_info/gift/gift_screen_bloc.dart';
import 'package:socbay/blocs/user_info/gift/gift_screen_state.dart';
import 'package:socbay/data/event_bus/event_bus_event.dart';
import 'package:socbay/data/model/gift_response.dart';
import 'package:socbay/routes.dart';
import 'package:socbay/utils/context_extension.dart';
import 'package:socbay/utils/image_util.dart';
import 'package:socbay/widgets/loading_indicator.dart';
import 'package:socbay/widgets/my_app_bar.dart';

import '../../application.dart';
import '../../blocs/user_info/gift/gift_screen_event.dart';
import '../../constants/constants.dart';
import '../../utils/color_util.dart';

class GiftScreen extends StatefulWidget {
  const GiftScreen({super.key});

  @override
  State<GiftScreen> createState() => _GiftScreenState();
}

class _GiftScreenState extends State<GiftScreen> with TickerProviderStateMixin {
  late GiftScreenBloc _bloc;
  late TabController _tabController;
  late StreamSubscription _reloadGiftStream;

  @override
  void initState() {
    super.initState();
    _bloc = BlocProvider.of(context);
    _bloc.add(GiftScreenStartedEvent());
    _tabController = TabController(
      length: 2,
      initialIndex: 0,
      vsync: this,
    );
    _tabController.addListener(() {
      if (_tabController.index != _tabController.previousIndex) {
        _bloc.add(GiftScreenTabPressEvent(_tabController.index));
      }
    });


    _reloadGiftStream = App.instance.eventBus
        .on<EventBusReloadGiftEvent>()
        .listen((event) {
      _bloc.add(GiftScreenStartedEvent());
    });
  }

  @override
  void dispose() {
    super.dispose();
    _bloc.close();
    _reloadGiftStream.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GiftScreenBloc, GiftScreenState>(
        builder: _builder, listener: _listener);
  }

  void _listener(BuildContext context, GiftScreenState state) {}

  Widget _builder(BuildContext context, GiftScreenState state) {
    return Scaffold(
      appBar: MyAppBar(
        title: "Đổi quà",
        isBackNavigation: true,
        centerTitle: true,
      ),
      body: LoadingIndicator(
        isLoading: _bloc.isLoading,
        child: Column(
          children: [
            TabBar(
              controller: _tabController,
              indicatorColor: ColorUtil.bangladeshGreen,
              overlayColor: WidgetStateProperty.all(ColorUtil.transparent),
              tabs: [
                _buildTab('Danh sách quà', _tabController.index == 0),
                _buildTab('Danh sách quà đã đổi', _tabController.index == 1),
              ],
            ),
            Expanded(
              child: IndexedStack(
                index: _tabController.index,
                children: [
                  _buildGiftList(_bloc.giftList, true),
                  _buildGiftList(_bloc.giftReceiveList, false),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Tab _buildTab(text, bool isSelected) {
    return Tab(
        height: 64,
        child: Text(
          text,
          style: TextStyle(
              fontSize: 20,
              color: isSelected ? ColorUtil.bangladeshGreen : Colors.black),
        ));
  }

  Widget _buildGiftList(List<GiftResponse> list, bool isMyGift) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Visibility(
        visible: _bloc.isLoading || list.isNotEmpty,
        replacement: const Center(
          child: Padding(
              padding: EdgeInsets.only(bottom: 80), child: Text("Trống")),
        ),
        child: AlignedGridView.count(
            shrinkWrap: true,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            crossAxisCount: 2,
            itemCount: list.length,
            itemBuilder: (BuildContext context, int index) {
              final GiftResponse item = list[index];
              return GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, Routes.giftDetail,
                          arguments: {"gift": item, "is_my_gift": isMyGift})
                      .then((value) {
                    if (value == true) {
                      _bloc.add(GiftScreenStartedEvent());
                    }
                  });
                },
                child: Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ImageUtil.loadNetWorkImage(
                            url: item.image ?? "",
                            width: double.infinity,
                            height: context.width / 2 - paddingHorizontal * 2,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.name ?? "",
                            maxLines: 1,
                            style: const TextStyle(
                                overflow: TextOverflow.ellipsis,
                                fontSize: 13,
                                color: ColorUtil.bangladeshGreen),
                          ),
                          const SizedBox(height: 8),
                          Text('${item.point} điểm ',
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: ColorUtil.brightYellow))
                        ],
                      ),
                    )),
              );
            }),
      ),
    );
  }
}
