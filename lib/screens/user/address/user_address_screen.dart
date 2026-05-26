import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socbay/application.dart';
import 'package:socbay/blocs/user_info/user_address/user_address_screen_bloc.dart';
import 'package:socbay/blocs/user_info/user_address/user_address_screen_event.dart';
import 'package:socbay/blocs/user_info/user_address/user_address_screen_state.dart';
import 'package:socbay/constants/constants.dart';
import 'package:socbay/data/event_bus/event_bus_event.dart';
import 'package:socbay/data/model/home_service_model.dart';
import 'package:socbay/data/model/user_address.dart';
import 'package:socbay/routes.dart';
import 'package:socbay/utils/color_util.dart';
import 'package:socbay/widgets/dialog/custom_alert_dialog.dart';
import 'package:socbay/widgets/loading_indicator.dart';
import 'package:socbay/widgets/my_app_bar.dart';
import 'package:socbay/widgets/my_button.dart';

class UserAddressScreen extends StatefulWidget {
  const UserAddressScreen({super.key});

  @override
  State<UserAddressScreen> createState() => _UserAddressScreenState();
}

class _UserAddressScreenState extends State<UserAddressScreen> {
  late UserAddressScreenBloc _bloc;
  late UserAddress user;
  // late HomeBloc _homeBloc;
  late StreamSubscription _eventBusStream;
  List<HomeServiceModel> services = [];
  @override
  void initState() {
    super.initState();
    _bloc = BlocProvider.of(context);
    _bloc.add(UserAddressScreenGetAddressEvent());
    // _homeBloc = BlocProvider.of(context);
    _eventBusStream = App.instance.eventBus
        .on<EventBusReloadUserAddressEvent>()
        .listen((event) {
          _bloc.add(UserAddressScreenGetAddressEvent());
        });
  }

  @override
  void dispose() {
    super.dispose();
    _eventBusStream.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserAddressScreenBloc, UserAddressScreenState>(
      builder: _builder,
      listener: _listener,
    );
  }

  void _listener(BuildContext context, UserAddressScreenState state) {
    if (_bloc.isChange) {
      // Navigator.pushNamed(context, Routes.serviceScreen, arguments: {
      //   "index": "",
      //   "listService": _homeBloc.services,
      // }).then((_) => setState(() {
      //
      // }));
      Navigator.of(context).pop(user);
    }
  }

  Widget _builder(BuildContext context, UserAddressScreenState state) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: MyAppBar(
          title: "Địa chỉ của tôi",
          isBackNavigation: true,
          onBack: _onGoBack,
        ),
        body: LoadingIndicator(
          isLoading: _bloc.isLoading,
          child: RefreshIndicator(
            onRefresh: () async {
              _bloc.add(UserAddressScreenGetAddressEvent());
            },
            child: ListView(
              children: [
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemBuilder: _itemBuilder,
                  separatorBuilder: _separatorBuilder,
                  itemCount: _bloc.listUserAddress.length,
                ),
                if (_bloc.listUserAddress.length <= 10)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: paddingHorizontal,
                    ),
                    child: DefaultOutlinedButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          Routes.addUserAddressScreen,
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            "Thêm địa chỉ mới",
                            style: TextStyle(color: ColorUtil.bangladeshGreen),
                          ),
                          Icon(Icons.add, color: ColorUtil.bangladeshGreen),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _separatorBuilder(BuildContext context, int index) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: paddingHorizontal),
      child: Divider(height: 0, thickness: 1),
    );
  }

  Widget _itemBuilder(BuildContext context, int index) {
    final UserAddress item = _bloc.listUserAddress[index];
    return InkWell(
      onTap: () async {
        if (!item.isDefaultAddress()) {
          user = item;
          _bloc.add(UserAddressScreenSetDefaultEvent(item));
        }
      },
      child: Dismissible(
        key: Key(item.id ?? ""),
        confirmDismiss: (DismissDirection direction) async {
          _onDrag(direction, item);
          return false;
        },
        direction: item.isDefaultAddress()
            ? DismissDirection.startToEnd
            : DismissDirection.horizontal,
        secondaryBackground: Container(
          color: Colors.red,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.centerRight,
          child: const Icon(Icons.delete_forever, color: Colors.white),
        ),
        background: Container(
          color: ColorUtil.bangladeshGreen,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.centerLeft,
          child: const Icon(Icons.edit, color: Colors.white),
        ),
        child: Container(
          width: double.infinity,
          color: Colors.transparent,
          padding: const EdgeInsets.symmetric(
            horizontal: paddingHorizontal,
            vertical: 8,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${item.name}", overflow: TextOverflow.ellipsis),
                    Text("${item.phone}", overflow: TextOverflow.ellipsis),
                    Text(
                      "${item.address}",
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              if (item.isDefaultAddress())
                const Icon(Icons.check, color: ColorUtil.bangladeshGreen),
            ],
          ),
        ),
      ),
    );
  }

  void _onDrag(DismissDirection direction, UserAddress item) {
    if (direction == DismissDirection.endToStart) {
      CustomAlertDialog.show(
        context,
        isShowTitle: false,
        content: "Xóa địa chỉ?",
        leftText: "Hủy",
        rightText: "Xóa",
        isRightPositive: true,
        rightAction: () {
          Navigator.pop(context);
          _bloc.add(UserAddressScreenDeleteAddressEvent(item));
        },
      );
    } else if (direction == DismissDirection.startToEnd) {
      Navigator.pushNamed(
        context,
        Routes.addUserAddressScreen,
        arguments: item,
      );
    }
  }

  void _onGoBack() {
    for (var element in _bloc.listUserAddress) {
      if (element.isDefaultAddress()) {
        Navigator.pop(context, {'userAddress': element});
      }
    }
  }

  Future<bool> _onWillPop() async {
    _onGoBack();
    return true;
  }
}
