import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:full_screen_image_null_safe/full_screen_image_null_safe.dart';
import 'package:image_picker/image_picker.dart';
import 'package:socbay/blocs/home/staff_info/staff_info_screen_bloc.dart';
import 'package:socbay/blocs/home/staff_info/staff_info_screen_event.dart';
import 'package:socbay/blocs/home/staff_info/staff_info_screen_state.dart';
import 'package:socbay/config/app_config.dart';
import 'package:socbay/constants/constants.dart';
import 'package:socbay/data/model/user_profile.dart';
import 'package:socbay/paths/images.dart';
import 'package:socbay/utils/color_util.dart';
import 'package:socbay/utils/file_util.dart';
import 'package:socbay/utils/image_util.dart';
import 'package:socbay/utils/theme_util.dart';
import 'package:socbay/widgets/dialog/custom_alert_dialog.dart';
import 'package:socbay/widgets/my_app_bar.dart';

class StaffProfileScreen extends StatefulWidget {
  const StaffProfileScreen({super.key});

  @override
  State<StaffProfileScreen> createState() => _StaffProfileScreenState();
}

class _StaffProfileScreenState extends State<StaffProfileScreen> {
  late StaffInfoScreenBloc _bloc;
  late UserProfile staffInfo;
  bool isPickDone = false;
  String _localte = "";
  List<String> _services = [];
  late final ImagePicker _picker;

  @override
  void initState() {
    _bloc = BlocProvider.of(context);

    staffInfo = _bloc.args["staffInfo"];
    _bloc.add(StaffInfoScreenStartedEvent());
    // _localte = _bloc.localte;
    // _services = _bloc.services;
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
      body: Center(
        child: ListView(
          padding: const EdgeInsets.symmetric(
              horizontal: paddingHorizontal, vertical: paddingVertical),
          children: [
            Row(
              children: [
                // staffInfo.avatar != null
                //     ? fullScreenHeroWidget(
                //         "$protocol${AppConfig.instance.values.apiUrl}/" +
                //             staffInfo.avatar!)
                //     : ClipRRect(
                //         borderRadius: BorderRadius.circular(14),
                //         child: ImageUtil.loadNetWorkImage(
                //             url: '', height: 100, width: 100),
                //       ),
                _buildAvatar(),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${staffInfo.username}',
                      style: const TextStyle(
                          color: ColorUtil.bangladeshGreen,
                          fontSize: 20,
                          fontWeight: MyFontWeight.extraBold),
                    ),
                    Text(
                      '${staffInfo.phone}',
                      style: const TextStyle(
                          color: ColorUtil.raisinBlack,
                          fontWeight: MyFontWeight.ultraBold,
                          decoration: TextDecoration.underline),
                    )
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
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                ImageUtil.loadAssetsImage(
                    fileName: staffInfo.phone!.isNotEmpty
                        ? Images.iconCheck
                        : Images.iconCancel,
                    width: 16,
                    height: 16),
                const SizedBox(width: 4),
                const Text('Đã xác minh số điện thoại')
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
                    height: 16),
                const SizedBox(width: 4),
                const Text('Đã xác minh chứng minh thư')
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'Dịch vụ cung cấp',
              style: TextStyle(
                  color: ColorUtil.raisinBlack,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            _services.isNotEmpty
                ? Wrap(
              children: _services
                  .map((service) =>
                  Container(
                    margin: const EdgeInsets.only(left: 3.0),
                    child: TextButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          //<-- SEE HERE
                            side: const BorderSide(
                                width: 1.0, color: ColorUtil.bangladeshGreen),
                            padding: const EdgeInsets.all(10.0)
                        ),
                        child: Text(service)
                    ),)
              )
                  .toList(),
            )
                : const Text(
              'Trống!',
              style: TextStyle(
                  color: ColorUtil.bangladeshGreen,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Khu vực',
              style: TextStyle(
                  color: ColorUtil.raisinBlack,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              _localte,
              style: const TextStyle(
                  color: ColorUtil.bangladeshGreen,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
          ],
        ),
      )
    );
  }

  // void _saveFavouriteStaff() {
  //   if (_bloc.isFavourite) {
  //     _bloc.add(StaffInfoScreenUnLikeStaffEvent(staffInfo.id!));
  //   } else {
  //     _bloc.add(StaffInfoScreenLikeStaffEvent(staffInfo.id!));
  //   }
  // }

  Widget _buildAvatar() {
    return Center(
      child: GestureDetector(
        onTap: _onEditAvatar,
        child: Stack(
          children: [
            ClipRRect(
                borderRadius: BorderRadius.circular(140),
                child: staffInfo.avatar != null
                    ? Image.network(
                    "$protocol${AppConfig.instance.values.apiUrl}${staffInfo.avatar!}",
                    height: 160, width: 160, fit: BoxFit.cover)
                    : ImageUtil.loadAssetsImage(
                    fileName: Images.iconAdvise,
                    width: 160,
                    height: 160)),
            Positioned(
                bottom: 16,
                right: 16,
                child: GestureDetector(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(60),
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 25,
                    ),
                  ),
                  onTap: () {},
                ))
          ],
        ),
      ),
    );
  }

  void _onEditAvatar() async {
    File? file = await onGetPhotoFromGallery(
        context: context, funcPermission: () {}, picker: _picker);
    if (file != null) {
      setState(() {
        // _bloc.add(UploadImageEvent(file));
      });
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
          //fit: BoxFit.cover,
        ),
      ),
    );
  }
}
